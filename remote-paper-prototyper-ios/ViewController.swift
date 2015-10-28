//
//  ViewController.swift
//  remote-paper-prototyper-ios
//
//  Created by Kevin Chen on 10/3/14.
//  Copyright (c) 2014 aspin. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate, CLLocationManagerDelegate {
    
    // UI Elements
    @IBOutlet weak var task: UILabel!

    // MeteorDDP Member
    var meteorClient : MeteorClient!

    // OpenTok Streaming Member
    var session : OTSession!
    var publisher: OTPublisher!
    var subscriber: OTSubscriber!
    
    var syncCode = ""
    var apiKey = ""
    var streamId = ""
    var token = ""
    var messageId = ""
    
    // Gesture Recognition Members
    let tapGestureRecognizer = UITapGestureRecognizer()
    let pinchGestureRecognizer = UIPinchGestureRecognizer()
    let swipeGestureRecognizer = UISwipeGestureRecognizer()
    let longPressGestureRecognizer = UILongPressGestureRecognizer()
    let rotateGestureRecognizer = UIRotationGestureRecognizer()
    var panGestureRecognizer = UIPanGestureRecognizer()
    
    let locationManager = CLLocationManager()
    
    // -------------------------
    // MARK: View Initialization
    // -------------------------
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initMeteor()
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        self.view.addGestureRecognizer(self.panGestureRecognizer)
        
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.showSyncCodeAlert()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showSyncCodeAlert() {
        let alert = UIAlertController(title: "Sync", message: "Enter the sync code below", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.syncCode = (alert.textFields![0] as UITextField).text!
            
            let subscriptionParams = ["session": self.syncCode]
            self.meteorClient.addSubscription("messages", withParameters: [subscriptionParams])
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "messageChanged:", name: "messages_changed", object: nil)
            
            self.initTask()
            // self.initStream()
        }))
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField) in
            textField.placeholder = ""
            textField.secureTextEntry = true
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func messageChanged(notification: NSNotification) {
        if let result = notification.userInfo as? [String:String] {
            if result["_id"] == self.messageId && result["type"] == "task" {
                self.task.text = result["content"]
            }
        }
    }
    
    // --------------------------------------------
    // MARK: MeteorDDP Initialization and Observers
    // --------------------------------------------
    func initMeteor() {
        self.meteorClient = (UIApplication.sharedApplication().delegate as! AppDelegate).meteorClient

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
            if let result = response["result"] as? [String: String] {
                self.streamId = result["session"]!
                self.apiKey = result["key"]!
                self.token = result["token"]!
                self.session = OTSession(apiKey: self.apiKey, sessionId: self.streamId, delegate: self)
                self.doConnect()
            } else {
                self.showSyncCodeAlert()
            }
        })
    }
    
    // ----------------------------------------
    // MARK: OpenTok Initialization and Methods
    // ----------------------------------------
    func doConnect() {
        var error : OTError? = nil
        
        self.session.connectWithToken(token, error: &error)
        if (error != nil) {
            // self.showAlert
        }
    }
    
    func doSubscribe(stream: OTStream) {
        self.subscriber = OTSubscriber(stream: stream, delegate: self)
    
        var error : OTError? = nil
        self.session.subscribe(self.subscriber, error: &error)
        if (error != nil) {
            // self.showAlert
        }
    }
    
    func cleanupSubscriber() {
        self.subscriber.view.removeFromSuperview()
        //self.subscriber = nil
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
        self.doSubscribe(stream)
    }
    
    func session(session: OTSession!, streamDestroyed stream: OTStream!) {
        print("session streamDestroyed \(stream.streamId)")
        if (self.subscriber.stream.streamId == stream.streamId) {
            self.cleanupSubscriber()
        }
    }
    
    func session(session: OTSession!, connectionCreated connection: OTConnection!) {
        print("session connectionCreated \(connection.connectionId)")
    }
    
    func session(session: OTSession!, connectionDestroyed connection: OTConnection!) {
        print("session connectionDestroyed \(connection.connectionId)")
        if (self.subscriber.stream.connection.connectionId == connection.connectionId) {
            self.cleanupSubscriber()
        }
    }
    
    func session(session: OTSession!, didFailWithError error: OTError!) {
        print("didFailWithError: \(error)")
    }
   
    // -------------------------------------
    // MARK: OTSubscriber delegate callbacks
    // -------------------------------------
    func subscriberDidConnectToStream(subscriber: OTSubscriberKit!) {
        print("subscriberDidConnectToStream \(subscriber.stream.connection.connectionId)")
        assert(subscriber == self.subscriber)
        self.subscriber.view.frame = CGRectMake(0, 20, 320, 460)
        self.view.addSubview(self.subscriber.view)
    }
    
    func subscriber(subscriber: OTSubscriberKit!, didFailWithError error: OTError!) {
        print("")
    }
  
    // ------------------------------------
    // MARK: OTPublisher delegate callbacks
    // ------------------------------------
    func publisher(publisher: OTPublisherKit!, streamCreated stream: OTStream!) {
        self.doSubscribe(stream)
    }
    
    func publisher(publisher: OTPublisherKit!, streamDestroyed stream: OTStream!) {
        if (self.subscriber.stream.streamId == stream.streamId) {
            self.cleanupSubscriber()
        }
    }
    
    func publisher(publisher: OTPublisherKit!, didFailWithError: OTError!) {
    }
    
    func showAlert(string: String) {
//        dispatch_async(dispatch_get_main_queue(), {
//            var alert : UIAlertView = UIAlertView(title: "OTError", message: string, delegate: self, cancelButtonTitle: "OK", otherButtonTitles: nil)
//            }, alert.show())
    }

    // ---------------------------------
    // MARK: Gesture Recognition Methods
    // ---------------------------------
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: AnyObject? = event!.allTouches()?.first
        let touchPoint = touch?.locationInView(self.view)
        
        let xcor = touchPoint?.x
        let ycor = touchPoint?.y
        let tapData = ["x": Float(xcor!), "y": Float(ycor!)]
        
        print("TAP: x: \(xcor); y: \(ycor)")
        
        self.meteorClient.callMethodName("createTap", parameters: [tapData], responseCallback: nil)
    }
    
    func handlePan(pan: UIPanGestureRecognizer) {
        let motion = pan.translationInView(self.view) // gives relative position from original tap...
        print("PAN: x: \(motion.x), y: \(motion.y)")
        
        let xcor = motion.x
        let ycor = motion.y
        let panData = ["x": Float(xcor), "y": Float(ycor)]
        
        print("PAN: x: \(xcor); y: \(ycor)")
        self.meteorClient.callMethodName("panUpdate", parameters: [panData], responseCallback: nil)
    }
    
    // ---------------------------------
    // MARK: CoreLocation Delegate
    // ---------------------------------
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("got location")
    }

}


