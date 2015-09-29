//
//  ViewController.swift
//  remote-paper-prototyper-ios
//
//  Created by Kevin Chen on 10/3/14.
//  Copyright (c) 2014 aspin. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices

class ViewController: UIViewController, OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate {
    
    // MARK: UI Elements
    @IBOutlet weak var task: UILabel!

    // MARK: MeteorDDP Member
    var meteorClient = initializeMeteor("1", "ws://localhost:3000/websocket");

    // MARK: OpenTok Streaming Member
    var session : OTSession!
    var publisher: OTPublisher!
    var subscriber: OTSubscriber!
    
    var syncCode = ""
    var APIKey = ""
    var SessionID = ""
    var Token = ""
    
    // MARK: Gesture Recognition Members
    let tapGestureRecognizer = UITapGestureRecognizer()
    let pinchGestureRecognizer = UIPinchGestureRecognizer()
    let swipeGestureRecognizer = UISwipeGestureRecognizer()
    let longPressGestureRecognizer = UILongPressGestureRecognizer()
    let rotateGestureRecognizer = UIRotationGestureRecognizer()
    var panGestureRecognizer = UIPanGestureRecognizer()
    
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
        
        // bit not elegant...
        let _ = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "getNewTask", userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        let alert = UIAlertController(title: "Sync", message: "Enter the designer's sync code below", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.syncCode = (alert.textFields![0] as UITextField).text!
            self.getSession()
        }))
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField) in
            textField.placeholder = ""
            textField.secureTextEntry = true
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // --------------------------------------------
    // MARK: MeteorDDP Initialization and Observers
    // --------------------------------------------
    func initMeteor() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportConnection", name: MeteorClientDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportDisconnection", name: MeteorClientDidDisconnectNotification, object: nil)
        
        self.meteorClient.addSubscription("messages")
        self.meteorClient.addSubscription("sessions")
    }
    
    func reportConnection() {
        print("================> connected to server!")
    }
    
    func reportDisconnection() {
        print("================> disconnected from server!")
    }
    
    func getNewTask() {
        self.meteorClient.callMethodName("returnNewTask", parameters: nil, responseCallback: {(response, error) -> Void in
            print("\(response)")
            if (response != nil) {
                self.task.text = (response["result"] as! String)
            }
        })
    }
    
    func getSession() {
        self.meteorClient.callMethodName("getSession", parameters: ["subscriber"] as [AnyObject], responseCallback: {(response, error) -> Void in
            print("[getSession]: \(response)")
            let result = response["result"] as! [String: String]
            self.SessionID = result["session"]!
            self.APIKey = result["key"]!
            self.Token = result["token"]!
            self.session = OTSession(apiKey: self.APIKey, sessionId: self.SessionID, delegate: self)
            self.doConnect()
        })
    }

    // having some trouble with this...
//    func addMeteorObserver() {
//        self.meteorMessages.addObserver(self, forKeyPath: "newTaskSent", options: nil, context: nil)
//    }
//    
//    func newTaskSent() {
//        println("got a new task!")
//    }
    
    // ----------------------------------------
    // MARK: OpenTok Initialization and Methods
    // ----------------------------------------
    func doConnect() {
        var error : OTError? = nil
        
        self.session.connectWithToken(Token, error: &error)
        if (error != nil) {
            // self.showAlert
        }
    }
    
    func doPublish() {
//        self.publisher = OTPublisher(delegate: self, name: UIDevice.currentDevice().name)
//
//        var error : OTError? = nil
//        self.session.publish(self.publisher, error: &error)
//        if (error != nil) {
//            // self.showAlert
//        }
//        
//        // self.view.addSubview(self.publisher.view!)
//        // self.publisher.view.frame = CGRectMake(0, 0, 320, 240)
    }
    
    func cleanupPublisher() {
//        self.publisher.view.removeFromSuperview()
//        self.publisher = nil
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
        // self.doPublish()
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
        self.cleanupPublisher()
    }
    
    func publisher(publisher: OTPublisherKit!, didFailWithError: OTError!) {
        self.cleanupPublisher()
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
        var touch: AnyObject? = event!.allTouches()?.first
        var touchPoint = touch?.locationInView(self.view)
        
        var xcor = touchPoint?.x
        var ycor = touchPoint?.y
        var tapData = ["x": Float(xcor!), "y": Float(ycor!)]
        
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

}


