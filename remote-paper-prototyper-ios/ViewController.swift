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

class RPPTController: UIViewController, OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate, CLLocationManagerDelegate {
    
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
    
    // -------------------------
    // MARK: View Initialization
    // -------------------------
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        tapGestureRecognizer = UITapGestureRecognizer()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        
        super.viewDidLoad()
        
        initMeteor()

        self.view.addGestureRecognizer(panGestureRecognizer)
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidAppear(animated: Bool) {
        showSyncCodeAlert()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showSyncCodeAlert() {
        let alert = UIAlertController(title: "Sync", message: "Enter the sync code below", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.syncCode = (alert.textFields![0] as UITextField).text!
            
            let subscriptionParams = ["session": self.syncCode]
            self.meteorClient.addSubscription("messages", withParameters: [subscriptionParams])
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "messageChanged:", name: "messages_changed", object: nil)
            
            self.initTask()
            self.initStream()
        }))
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField) in
            textField.placeholder = ""
        })
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func messageChanged(notification: NSNotification) {
        if let result = notification.userInfo as? [String:String] {
            if result["_id"] == self.messageId && result["type"] == "task" {
                task.text = result["content"]
                AudioServicesPlaySystemSound(1003)
            }
        }
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
        meteorClient = (UIApplication.sharedApplication().delegate as! AppDelegate).meteorClient

    }
    
    func initTask() {
        self.meteorClient.callMethodName("getTaskId", parameters: [self.syncCode]) { (response, error) -> Void in
            if let result = response["result"] as? [String: String] {
                self.task.text = result["content"]
                self.messageId = result["_id"]!
            }
        }
    }
    
    func initStream() {
        self.meteorClient.callMethodName("getStreamData", parameters: [self.syncCode, "subscriber"] as [AnyObject], responseCallback: {(response, error) -> Void in
            if let err = error {
                self.showAlertWithMessage("Could not stream session keys.", message: "Try refreshing your web client and entering in a new sync code.")
                print("\(err.localizedDescription)")
            } else if let result = response["result"] as? [String: String] {
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
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // ----------------------------------------
    // MARK: OpenTok Initialization and Methods
    // ----------------------------------------
    func doConnect() {
        var error : OTError? = nil
        
        self.session.connectWithToken(token, error: &error)
        if (error != nil) {
             showAlert(error!.localizedDescription)
        }
    }
    
    func doSubscribe(stream: OTStream) {
        subscriber = OTSubscriber(stream: stream, delegate: self)
    
        var error : OTError? = nil
        session.subscribe(self.subscriber, error: &error)
        if (error != nil) {
             showAlert(error!.localizedDescription)
        }
    }
    
    func cleanupSubscriber() {
        subscriber.view.removeFromSuperview()
        subscriber = nil
    }
    
    // ----------------------------------
    // MARK: OTSession Delegate Callbacks
    // ----------------------------------
    func sessionDidConnect(session: OTSession!) {
        print("sessionDidConnect \(session.sessionId)")
    }
    
    func sessionDidDisconnect(session: OTSession!) {
        let alert = "Session disconnected: \(session.sessionId)"
        print("sessionDidDisconnect \(alert)")
    }
    
    func session(session: OTSession!, streamCreated stream: OTStream!) {
        print("session streamCreated \(session.sessionId)")
        doSubscribe(stream)
    }
    
    func session(session: OTSession!, streamDestroyed stream: OTStream!) {
        print("session streamDestroyed \(stream.streamId)")
        if (subscriber.stream.streamId == stream.streamId) {
            cleanupSubscriber()
        }
    }
    
    func session(session: OTSession!, connectionCreated connection: OTConnection!) {
        print("session connectionCreated \(connection.connectionId)")
    }
    
    func session(session: OTSession!, connectionDestroyed connection: OTConnection!) {
        print("session connectionDestroyed \(connection.connectionId)")
        if (subscriber.stream.connection.connectionId == connection.connectionId) {
            cleanupSubscriber()
        }
    }
    
    func session(session: OTSession!, didFailWithError error: OTError!) {
        print("didFailWithError: \(error.localizedDescription)")
    }
   
    // -------------------------------------
    // MARK: OTSubscriber delegate callbacks
    // -------------------------------------
    func subscriberDidConnectToStream(subscriber: OTSubscriberKit!) {
        print("subscriberDidConnectToStream \(subscriber.stream.connection.connectionId)")
        assert(subscriber == self.subscriber)
        let screenRect = UIScreen.mainScreen().bounds
        self.subscriber.view.frame = CGRectMake(0, 20, screenRect.width, screenRect.width * 1.4375)
        self.view.addSubview(self.subscriber.view)
        self.view.bringSubviewToFront(stopButton)
    }
    
    func subscriber(subscriber: OTSubscriberKit!, didFailWithError error: OTError!) {
        print("didFailWithError: \(error.localizedDescription)")
    }
  
    // ------------------------------------
    // MARK: OTPublisher delegate callbacks
    // ------------------------------------
    func publisher(publisher: OTPublisherKit!, streamCreated stream: OTStream!) {
        doSubscribe(stream)
    }
    
    func publisher(publisher: OTPublisherKit!, streamDestroyed stream: OTStream!) {
        if (subscriber.stream.streamId == stream.streamId) {
            cleanupSubscriber()
        }
    }
    
    func publisher(publisher: OTPublisherKit!, didFailWithError: OTError!) {
    }
    
    func showAlert(string: String) {
        showAlertWithMessage("OpenTok Error", message: string)
    }

    // ---------------------------------
    // MARK: Gesture Recognition Methods
    // ---------------------------------
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: AnyObject? = event!.allTouches()?.first
        let touchPoint = touch?.locationInView(self.view)
        
        lastX = Float((touchPoint?.x)!)
        lastY = Float((touchPoint?.y)!)
        sendTap(x: self.lastX, y: self.lastY)
    }
    
    func handlePan(pan: UIPanGestureRecognizer) {
        let motion = pan.translationInView(self.view)
        sendTap(x: lastX + Float(motion.x), y: lastY + Float(motion.y))
    }
    
    func sendTap(x x: Float, y: Float) {
        let (scaledX, scaledY) = scale(x: x, y: y)
        if scaledY < 500 {
            meteorClient.callMethodName("createTap", parameters: [syncCode, scaledX, scaledY], responseCallback: nil)
        }
    }
    
    func scale(x x: Float, y: Float) -> (Float, Float) {
        let screenRect = UIScreen.mainScreen().bounds,
            scaledX = x * 320 / Float(screenRect.width),
            scaledY = y * 460 / Float(screenRect.width * 1.4375)
        return (scaledX, scaledY)
    }
    
    // ---------------------------------
    // MARK: CoreLocation Delegate
    // ---------------------------------
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (self.syncCode != "") {
            let location = locations[0].coordinate, lat = location.latitude, lng = location.longitude
            let params = ["lat": lat, "lng": lng, "session": syncCode]
            meteorClient.callMethodName("/locations/insert", parameters: [params] , responseCallback: nil)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("\(error.localizedDescription)")
    }

}


