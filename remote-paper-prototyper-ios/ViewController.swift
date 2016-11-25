//
//  ViewController.swift
//  remote-paper-prototyper-ios
//
//  Created by Kevin Chen on 10/3/14.
//  Copyright (c) 2014 aspin. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import MobileCoreServices

class RPPTController: UIViewController, OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate {

    
    // UI Elements
    @IBOutlet weak var task: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var reSyncButton: UIButton!

    // MeteorDDP Member
    var meteorClient: MeteorClient!

    // OpenTok Streaming Member
    var session: OTSession!
    var publisher: OTPublisher!
    var subscriber: OTSubscriber!
    
    var syncCode = ""
    var apiKey = ""
    var streamId = ""
    var token = ""
    var messageId = ""
    
    // Gesture Recognition Members
    var tapGestureRecognizer: UITapGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var lastX = Float(0)
    var lastY = Float(0)
    
    let locationManager = CLLocationManager()
    
    let picker = UIImagePickerController()
    
    var textfield = UITextField()
    
    // -------------------------
    // MARK: View Initialization
    // -------------------------
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        tapGestureRecognizer = UITapGestureRecognizer()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(RPPTController.handlePan))
        
        super.viewDidLoad()
        
        initMeteor()

        self.view.addGestureRecognizer(panGestureRecognizer)
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        
        setUpCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (session == nil) {
            showSyncCodeAlert()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showSyncCodeAlert() {
        let alert = UIAlertController(title: "Sync", message: "Enter the sync code below", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.syncCode = (alert.textFields![0] as UITextField).text!
            
            self.meteorClient.addSubscription("messages", withParameters: [self.syncCode])
            NotificationCenter.default.addObserver(self, selector: #selector(RPPTController.messageChanged), name: NSNotification.Name(rawValue: "messages_changed"), object: nil)
            (UIApplication.shared.delegate as! AppDelegate).syncCode = self.syncCode
            self.initTask()
            self.initStream()
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = ""
        })
        present(alert, animated: true, completion: nil)
    }
    
    func setUpCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            if let mediaTypes = UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.camera) {
                picker.sourceType = .camera
                picker.mediaTypes = [kUTTypeImage as String]
            }
        }
    }
    
    func messageChanged(notification: NSNotification) {
        if let result = notification.userInfo as? [String:String] {
            if result["_id"] == self.messageId && result["type"] == "task" {
                task.text = result["content"]
                AudioServicesPlaySystemSound(1003)
            }
            if result["keyboard"] == "show" && result["keyboard_x"] != nil && result["keyboard_y"] != nil && result["keyboard_height"] != nil && result["keyboard_width"] != nil {
                self.setTextfield(x: CGFloat(Double(result["keyboard_x"]!)!), y: CGFloat(Double(result["keyboard_y"]!)!), width: CGFloat(Double(result["keyboard_width"]!)!), height: CGFloat(Double(result["keyboard_height"]!)!))
            }
            else if result["keyboard"] == "hide" {
                self.textfield.resignFirstResponder()
            }
            if result["camera"] == "show" {
                self.present(picker, animated: true, completion: nil)
            }
            else if result["camera"] == "hide" {
                picker.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func setTextfield(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        textfield.frame = CGRect(x: x, y: y, width: width, height: height)
        self.view.addSubview(textfield)
        self.textfield.becomeFirstResponder()
    }
    
    func resetStreams() {
        if let sess = session {
            var error : OTError? = nil
            sess.disconnect(&error)
            subscriber.view.removeFromSuperview()
            
        }
    }
    
    @IBAction func stopButtonTapped(sender: AnyObject) {
        resetStreams()
    }
    
    @IBAction func resyncButtonTapped(sender: AnyObject) {
        resetStreams()
        showSyncCodeAlert()
    }
    // --------------------------------------------
    // MARK: MeteorDDP Initialization and Observers
    // --------------------------------------------
    func initMeteor() {
        meteorClient = (UIApplication.shared.delegate as! AppDelegate).meteorClient

    }
    
    func initTask() {
        self.meteorClient.callMethodName("getTaskId", parameters: [self.syncCode]) { (response, error) -> Void in
            if let result = response?["result"] as? [String: String] {
                self.task.text = result["content"]
                self.messageId = result["_id"]!
            }
        }
    }
    
    func initStream() {
        self.meteorClient.callMethodName("getStreamData", parameters: [self.syncCode as AnyObject, "subscriber" as AnyObject] as [AnyObject], responseCallback: {(response, error) -> Void in
            if let err = error {
                self.showAlertWithMessage(title: "Could not get stream key.", message: "Try refreshing your web client and entering in a new sync code.")
                print("\(err.localizedDescription)")
            } else if let result = response?["result"] as? [String: String] {
                self.streamId = result["session"]!
                self.apiKey = result["key"]!
                self.token = result["token"]!
                self.session = OTSession(apiKey: self.apiKey, sessionId: self.streamId, delegate: self)
                
                self.locationManager.startUpdatingLocation()
                self.doConnect()
            } else {
                self.showSyncCodeAlert()
            }
        })
    }
    
    func showAlertWithMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // ----------------------------------------
    // MARK: OpenTok Initialization and Methods
    // ----------------------------------------
    func doConnect() {
        var error : OTError? = nil
        
        self.session.connect(withToken: token, error: &error)
        if (error != nil) {
             showAlert(string: error!.localizedDescription)
        }
    }
    
    func doSubscribe(stream: OTStream) {
        subscriber = OTSubscriber(stream: stream, delegate: self)
    
        var error : OTError? = nil
        session.subscribe(self.subscriber, error: &error)
        if (error != nil) {
             showAlert(string: error!.localizedDescription)
        }
    }
    
    func cleanupSubscriber() {
        subscriber.view.removeFromSuperview()
        subscriber = nil
    }
    
    // ----------------------------------
    // MARK: OTSession Delegate Callbacks
    // ----------------------------------
    func sessionDidConnect(_ session: OTSession!) {
        print("sessionDidConnect \(session.sessionId)")
    }
    
    func sessionDidDisconnect(_ session: OTSession!) {
        let alert = "Session disconnected: \(session.sessionId)"
        print("sessionDidDisconnect \(alert)")
    }
    
    func session(_ session: OTSession!, streamCreated stream: OTStream!) {
        print("session streamCreated \(session.sessionId)")
        doSubscribe(stream: stream)
    }
    
    func session(_ session: OTSession!, streamDestroyed stream: OTStream!) {
        print("session streamDestroyed \(stream.streamId)")
        if (subscriber.stream.streamId == stream.streamId) {
            cleanupSubscriber()
        }
    }
    
    func session(_ session: OTSession!, connectionCreated connection: OTConnection!) {
        print("session connectionCreated \(connection.connectionId)")
    }
    
    func session(_ session: OTSession!, connectionDestroyed connection: OTConnection!) {
        print("session connectionDestroyed \(connection.connectionId)")
        if (subscriber.stream.connection.connectionId == connection.connectionId) {
            cleanupSubscriber()
        }
    }
    
    func session(_ session: OTSession!, didFailWithError error: OTError!) {
        print("didFailWithError: \(error.localizedDescription)")
    }
   
    // -------------------------------------
    // MARK: OTSubscriber delegate callbacks
    // -------------------------------------
    
    public func subscriberDidConnect(toStream subscriber: OTSubscriberKit!) {
        print("subscriberDidConnectToStream \(subscriber.stream.connection.connectionId)")
        assert(subscriber == self.subscriber)
        let screenRect = UIScreen.main.bounds
        self.subscriber.view.frame = CGRect(x: 0, y: 20, width: screenRect.width, height: screenRect.width * 1.4375)
        self.view.addSubview(self.subscriber.view)
        self.view.bringSubview(toFront: stopButton)
    }
    
    func subscriber(_ subscriber: OTSubscriberKit!, didFailWithError error: OTError!) {
        print("didFailWithError: \(error.localizedDescription)")
    }
  
    // ------------------------------------
    // MARK: OTPublisher delegate callbacks
    // ------------------------------------
    func publisher(_ publisher: OTPublisherKit!, didFailWithError: OTError!) {
    }
    
    func showAlert(string: String) {
        showAlertWithMessage(title: "OpenTok Error", message: string)
    }

    // ---------------------------------
    // MARK: Gesture Recognition Methods
    // ---------------------------------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject? = event!.allTouches?.first
        let touchPoint = touch?.location(in: self.view);
        
        lastX = Float((touchPoint?.x)!)
        lastY = Float((touchPoint?.y)!)
        sendTap(x: self.lastX, y: self.lastY)
    }
    
    func handlePan(pan: UIPanGestureRecognizer) {
        let motion = pan.translation(in: self.view)
        sendTap(x: lastX + Float(motion.x), y: lastY + Float(motion.y))
    }
    
    func sendTap(x: Float, y: Float) {
        let (scaledX, scaledY) = scale(x: x, y: y)
        if scaledY < 500 {
            meteorClient.callMethodName("createTap", parameters: [syncCode, scaledX, scaledY], responseCallback: nil)
        }
    }
    
    func scale(x: Float, y: Float) -> (Float, Float) {
        let screenRect = UIScreen.main.bounds,
            scaledX = x * 320 / Float(screenRect.width),
            scaledY = y * 460 / Float(screenRect.width * 1.4375)
        return (scaledX, scaledY)
    }
    
    // ---------------------------------
    // MARK: CoreLocation Delegate
    // ---------------------------------
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (self.syncCode != "") {
            let location = locations[0].coordinate, lat = location.latitude, lng = location.longitude
            let params = ["lat": lat, "lng": lng, "session": syncCode] as [String : Any]
            meteorClient.callMethodName("/locations/insert", parameters: [params] , responseCallback: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error.localizedDescription)")
    }
}


