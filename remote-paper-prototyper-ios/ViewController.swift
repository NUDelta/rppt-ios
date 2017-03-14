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
import MapKit

class RPPTController: UIViewController, OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherKitDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    
    // UI Elements
    @IBOutlet weak var task: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var reSyncButton: UIButton!

    // MeteorDDP Member
    var meteorClient: MeteorClient!

    // OpenTok Streaming Member
    var subscribingSession: OTSession!
    var publishingSession: OTSession!
    var publisher: OTPublisherKit!
    var subscriber: OTSubscriber!
    var capturer: ScreenCapturer!
    
    var syncCode = ""
    var messageId = ""
    
    // Gesture Recognition Members
    var tapGestureRecognizer: UITapGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var lastX = Float(0)
    var lastY = Float(0)
    
    let locationManager = CLLocationManager()
    let picker = UIImagePickerController()
    var textview = UITextView()
    var imageView = UIImageView()
    var overlayedImageView = UIImageView()
    var mapView = MKMapView()
    var photoArray = [UIImage]()
    
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
        
        textview.delegate = self
        textview.backgroundColor = UIColor.clear
        
        setUpCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (subscribingSession == nil || publishingSession == nil) {
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
            picker.sourceType = .camera
            picker.mediaTypes = [kUTTypeImage as String]
            picker.delegate = self
        }
    }

    func messageChanged(notification: NSNotification) {
        if let result = notification.userInfo as? [String:String] {
            print(result)
            if result["_id"] == self.messageId && result["type"] == "task" {
                task.text = result["content"]
                AudioServicesPlaySystemSound(1003)
            }
            if result["keyboard"] == "show" {
                self.setTextview(x: 50, y: self.view.frame.height - 256, width: self.view.frame.width - 10, height: 40)
            } else if result["keyboard"] == "hide" {
                self.textview.resignFirstResponder()
                self.textview.removeFromSuperview()
            }
            if result["camera"] == "show" {
                if (!(picker.isViewLoaded && picker.view.window != nil)) {
                    self.present(picker, animated: true, completion: nil)
                }
            } else if result["camera"] == "hide" {
                if (self.presentingViewController == picker) {
                    picker.dismiss(animated: true, completion: nil)
                }
            }
            if let overlayedImageXString = result["overlayedImage_x"], let overlayedImageYString = result["overlayedImage_y"], let overlayedImageHeightString = result["overlayedImage_height"], let overlayedImageWidthString = result["overlayedImage_width"], let imageEncoding = result["overlayedImage"]{
                let overlayedImageX = Double(overlayedImageXString)
                let overlayedImageY = Double(overlayedImageYString)
                let overlayedImageHeight = Double(overlayedImageHeightString)
                let overlayedImageWidth = Double(overlayedImageWidthString)
                if overlayedImageX != -999 && overlayedImageY != -999 && overlayedImageWidth != -999 && overlayedImageHeight != -999 {
                    self.overlayImage(x: CGFloat(overlayedImageX!), y: CGFloat(overlayedImageY!), height: CGFloat(overlayedImageHeight!), width: CGFloat(overlayedImageWidth!), imageEncoding: imageEncoding)
                }
            }
//            if let keyboardXString = result["keyboard_x"], let keyboardYString = result["keyboard_y"], let keyboardWidthString = result["keyboard_width"], let keyboardHeightString = result["keyboard_height"] {
//                let keyboardX = Double(keyboardXString)
//                let keyboardY = Double(keyboardYString)
//                let keyboardHeight = Double(keyboardHeightString)
//                let keyboardWidth = Double(keyboardWidthString)
//                if keyboardX != -999 && keyboardY != -999 && keyboardWidth != -999 && keyboardHeight != -999 {
//                    self.setTextview(x: CGFloat(keyboardX!), y: CGFloat(keyboardY!), width: CGFloat(keyboardWidth!), height: CGFloat(keyboardHeight!))
//                    self.textview.resignFirstResponder()
//                    self.textview.removeFromSuperview()
//                }
//            }
            if let mapXString = result["map_x"], let mapYString = result["map_y"], let mapWidthString = result["map_width"], let mapHeightString = result["map_height"] {
                let mapX = Double(mapXString)
                let mapY = Double(mapYString)
                let mapHeight = Double(mapHeightString)
                let mapWidth = Double(mapWidthString)
                if mapX != -999 && mapY != -999 && mapWidth != -999 && mapHeight != -999 {
                    self.setMapView(x: CGFloat(mapX!), y: CGFloat(mapY!), width: CGFloat(mapWidth!), height: CGFloat(mapHeight!), index: 0)
                } else {
                    self.mapView.removeFromSuperview()
                }
            }
            if let photoXString = result["photo_x"], let photoYString = result["photo_y"], let photoWidthString = result["photo_width"], let photoHeightString = result["photo_height"] {
                let photoX = Double(photoXString)
                let photoY = Double(photoYString)
                let photoHeight = Double(photoHeightString)
                let photoWidth = Double(photoWidthString)
                if photoX != -999 && photoY != -999 && photoWidth != -999 && photoHeight != -999 {
                    self.setImageView(x: CGFloat(photoX!), y: CGFloat(photoY!), width: CGFloat(photoWidth!), height: CGFloat(photoHeight!), index: 0)
                } else {
                    self.imageView.removeFromSuperview()
                }
            }
        }
    }
    
    func setTextview(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        textview.frame = CGRect(x: x, y: y, width: width, height: height)
        self.view.addSubview(textview)
        self.textview.becomeFirstResponder()
    }
    
    func setMapView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, index: Int) {
        mapView.frame = CGRect(x: x, y: y, width: width, height: height)
        self.view.addSubview(mapView)
        mapView.showsUserLocation = true
        if overlayedImageView.isDescendant(of: self.view) {
            self.view.insertSubview(mapView, belowSubview: overlayedImageView)
        } else {
            self.view.addSubview(mapView)
        }
    }
    
    func setImageView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, index: Int) {
        if (photoArray.count != 0) {
            imageView.frame = CGRect(x: x, y: y, width: width, height: height)
            imageView.image = photoArray.last!
            if overlayedImageView.isDescendant(of: self.view) {
                self.view.insertSubview(imageView, belowSubview: overlayedImageView)
            } else {
                self.view.addSubview(imageView)
            }
        }
    }
    
    func overlayImage(x: CGFloat, y: CGFloat, height: CGFloat, width: CGFloat, imageEncoding: String) {
        let dataDecoded = Data(base64Encoded: imageEncoding, options: .ignoreUnknownCharacters)
        let decodedimage = UIImage(data: dataDecoded!)
        overlayedImageView.frame = CGRect(x: x, y: y, width: width, height: height)
        overlayedImageView.image = decodedimage
        self.view.addSubview(overlayedImageView)
        self.view.bringSubview(toFront: overlayedImageView)
    }
    
    func sendMessage() {
        meteorClient.callMethodName("printKeyboardMessage", parameters: [syncCode, textview.text], responseCallback: nil)
    }
    
    func resetStreams() {
        //To fix
        if let sess = subscribingSession {
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
                var streamId = result["session"]!
                var apiKey = result["key"]!
                var token = result["token"]!
                self.subscribingSession = OTSession(apiKey: apiKey, sessionId: streamId, delegate: self)
                
                self.locationManager.startUpdatingLocation()
                self.doConnect(session: self.subscribingSession, token: token)
            } else {
                self.showSyncCodeAlert()
            }
        })
        self.meteorClient.callMethodName("getStreamData", parameters: [self.syncCode as AnyObject, "publisher" as AnyObject] as [AnyObject], responseCallback: {(response, error) -> Void in
            if let err = error {
                print("\(err.localizedDescription)")
            } else if let result = response?["result"] as? [String: String] {
                var streamId = result["session"]!
                var apiKey = result["key"]!
                var token = result["token"]!
                self.publishingSession = OTSession(apiKey: apiKey, sessionId: streamId, delegate: self)
                
                self.doConnect(session: self.publishingSession, token: token)
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
    func doConnect(session: OTSession, token: String) {
        var error : OTError? = nil
        
        session.connect(withToken: token, error: &error)
        if (error != nil) {
             showAlert(string: error!.localizedDescription)
        }
    }
    
    func doSubscribe(stream: OTStream) {
        subscriber = OTSubscriber(stream: stream, delegate: self)
    
        var error : OTError? = nil
        subscribingSession.subscribe(self.subscriber, error: &error)
        if (error != nil) {
             showAlert(string: error!.localizedDescription)
        }
    }
    
    func cleanupSubscriber() {
        subscriber.view.removeFromSuperview()
        subscriber = nil
    }
    
    func doPublish() {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        publisher = OTPublisherKit(delegate: self, settings: settings)
        publisher.videoType = .screen
        publisher.audioFallbackEnabled = false
        
        capturer = ScreenCapturer(withView: view)
        publisher.videoCapture = capturer
        
        var error : OTError? = nil
        publishingSession.publish(self.publisher, error: &error)
        
        if (error != nil) {
            showAlert(string: error!.localizedDescription)
        }
    }
    
    func cleanupPublisher() {
        publisher = nil
    }
    
    // ----------------------------------
    // MARK: OTSession Delegate Callbacks
    // ----------------------------------
    func sessionDidConnect(_ session: OTSession) {
        print("sessionDidConnect \(session.sessionId)")
        if (session.capabilities?.canPublish)! {
            doPublish()
        }
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        let alert = "Session disconnected: \(session.sessionId)"
        print("sessionDidDisconnect \(alert)")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("session streamCreated \(session.sessionId)")
        doSubscribe(stream: stream)
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("session streamDestroyed \(stream.streamId)")
        if (subscriber.stream!.streamId == stream.streamId) {
            cleanupSubscriber()
        } else if (publisher.stream!.streamId == stream.streamId) {
            cleanupPublisher()
        }
    }
    
    func session(_ session: OTSession, connectionCreated connection: OTConnection) {
        print("session connectionCreated \(connection.connectionId)")
    }
    
    func session(_ session: OTSession, connectionDestroyed connection: OTConnection) {
        print("session connectionDestroyed \(connection.connectionId)")
        if (subscriber.stream!.connection.connectionId == connection.connectionId) {
            cleanupSubscriber()
        } else if (publisher.stream!.connection.connectionId == connection.connectionId) {
            cleanupPublisher()
        }
    }

    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("didFailWithError: \(error.localizedDescription)")
    }
   
    // -------------------------------------
    // MARK: OTSubscriberKitDelegate callbacks
    // -------------------------------------
    
    public func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        print("subscriberDidConnectToStream \(subscriber.stream!.connection.connectionId)")
        assert(subscriber == self.subscriber)
        let screenRect = UIScreen.main.bounds
        self.subscriber.view.frame = CGRect(x: 0, y: 20, width: screenRect.width, height: screenRect.width * 1.4375)
        self.view.addSubview(self.subscriber.view)
        self.view.bringSubview(toFront: stopButton)
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("didFailWithError: \(error.localizedDescription)")
    }
  
    // ------------------------------------
    // MARK: OTPublisherKitDelegate callbacks
    // ------------------------------------
    
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        print("Now publishing.")
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        cleanupPublisher()
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
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
    // MARK: UIImagePickerController Delegate
    // ---------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        photoArray.append(info[UIImagePickerControllerOriginalImage] as! UIImage)
        picker.dismiss(animated: true, completion: nil)
    }
    
    // ---------------------------------
    // MARK: UITextView Delegate
    // ---------------------------------
    
    func textViewDidChange(_ textView: UITextView) {
        if (textview.text.characters.last) == "\n" {
            sendMessage()
            textview.text = ""
        }
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


