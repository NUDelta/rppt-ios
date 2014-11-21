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
    var meteorClient = initializeMeteor("pre2", "ws://rppt.meteor.com/websocket");
//    var meteorMessages : M13OrderedDictionary {
//        return self.meteorClient.collections["messages"] as M13OrderedDictionary
//    }

    // MARK: OpenTok Streaming Member
    var session : OTSession!
    var publisher: OTPublisher!
    var subscriber: OTSubscriber!
    
    let APIKey = "45090422"
    let SessionID = "1_MX40NTA5MDQyMn5-MTQxNjU1Njk0OTM2M35pc296bHpCa1g2cUFBUFlNV2YvNDNCVWZ-fg"
    let Token = "T1==cGFydG5lcl9pZD00NTA5MDQyMiZzaWc9MTlkNGRmODJkNzc5ZjYxNjVhM2RmNmJmZmY3NDViZmMwNjQ4M2Y1MTpyb2xlPXN1YnNjcmliZXImc2Vzc2lvbl9pZD0xX01YNDBOVEE1TURReU1uNS1NVFF4TmpVMU5qazBPVE0yTTM1cGMyOTZiSHBDYTFnMmNVRkJVRmxOVjJZdk5ETkNWV1otZmcmY3JlYXRlX3RpbWU9MTQxNjU1NzAwMiZub25jZT0wLjA4OTI0OTIxODQ5NTQ1MjA5JmV4cGlyZV90aW1lPTE0MTkxNDg5NDY="
    
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
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initMeteor()
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        self.view.addGestureRecognizer(self.panGestureRecognizer)
        
        self.session = OTSession(apiKey: APIKey, sessionId: SessionID, delegate: self)
        self.doConnect()
        
        // bit not elegant...
        let timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "getNewTask", userInfo: nil, repeats: true)
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
//        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "addMeteorObserver", userInfo: nil, repeats: false)
    }
    
    func reportConnection() {
        println("================> connected to server!")
    }
    
    func reportDisconnection() {
        println("================> disconnected from server!")
    }
    
    func getNewTask() {
        self.meteorClient.callMethodName("returnNewTask", parameters: nil, responseCallback: {(response, error) -> Void in
            println("\(response)")
            if (response != nil) {
                self.task.text = response["result"] as String
            }
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
        println("sessionDidConnect \(session.sessionId)")
        // self.doPublish()
    }
    
    func sessionDidDisconnect(session: OTSession!) {
        var alert = "Session disconnected: \(session.sessionId)"
        println("sessionDidDisconnect \(alert)")
    }
    
    func session(session: OTSession!, streamCreated stream: OTStream!) {
        println("session streamCreated \(session.sessionId)")
        self.doSubscribe(stream)
    }
    
    func session(session: OTSession!, streamDestroyed stream: OTStream!) {
        println("session streamDestroyed \(stream.streamId)")
        if (self.subscriber.stream.streamId == stream.streamId) {
            self.cleanupSubscriber()
        }
    }
    
    func session(session: OTSession!, connectionCreated connection: OTConnection!) {
        println("session connectionCreated \(connection.connectionId)")
    }
    
    func session(session: OTSession!, connectionDestroyed connection: OTConnection!) {
        println("session connectionDestroyed \(connection.connectionId)")
        if (self.subscriber.stream.connection.connectionId == connection.connectionId) {
            self.cleanupSubscriber()
        }
    }
    
    func session(session: OTSession!, didFailWithError error: OTError!) {
        println("didFailWithError: \(error)")
    }
   
    // -------------------------------------
    // MARK: OTSubscriber delegate callbacks
    // -------------------------------------
    func subscriberDidConnectToStream(subscriber: OTSubscriberKit!) {
        println("subscriberDidConnectToStream \(subscriber.stream.connection.connectionId)")
        assert(subscriber == self.subscriber)
        self.subscriber.view.frame = CGRectMake(0, 20, 320, 460)
        self.view.addSubview(self.subscriber.view)
    }
    
    func subscriber(subscriber: OTSubscriberKit!, didFailWithError error: OTError!) {
        println("")
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
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touch: AnyObject? = event.allTouches()?.anyObject()
        var touchPoint = touch?.locationInView(self.view)
        
        var xcor = touchPoint?.x
        var ycor = touchPoint?.y
        var tapData = ["x": Float(xcor!), "y": Float(ycor!)]
        
        println("TAP: x: \(xcor); y: \(ycor)")
        
        self.meteorClient.callMethodName("createTap", parameters: [tapData], responseCallback: nil)
    }
    
    func handlePan(pan: UIPanGestureRecognizer) {
        var motion = pan.translationInView(self.view) // gives relative position from original tap...
        println("PAN: x: \(motion.x), y: \(motion.y)")
        
        let xcor = motion.x
        let ycor = motion.y
        let panData = ["x": Float(xcor), "y": Float(ycor)]
        
        println("PAN: x: \(xcor); y: \(ycor)")
        self.meteorClient.callMethodName("panUpdate", parameters: [panData], responseCallback: nil)
    }

}


