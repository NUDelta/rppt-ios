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
    
    var meteorClient = initializeMeteor("pre2", "ws://localhost:3000/websocket");

    var session : OTSession!
    var publisher: OTPublisher!
    var subscriber: OTSubscriber!
    var tapGestureRecognizer : UITapGestureRecognizer!
    
    let height = 240
    let width = 320
    
    let APIKey = "45040222"
    let SessionID = "2_MX40NTA0MDIyMn5-MTQxNDc3NTMzNjIzOX5JQ2hRNkhMZTlJQ1NOd2hNbzBwSGNmbU9-fg"
    let Token = "T1==cGFydG5lcl9pZD00NTA0MDIyMiZzaWc9Y2IxMzM4YjBiMWJkYjNkZGZlNTg5ODEyNmU2ZGYyNTAyYTY1NTM4Yjpyb2xlPXN1YnNjcmliZXImc2Vzc2lvbl9pZD0yX01YNDBOVEEwTURJeU1uNS1NVFF4TkRjM05UTXpOakl6T1g1SlEyaFJOa2hNWlRsSlExTk9kMmhOYnpCd1NHTm1iVTktZmcmY3JlYXRlX3RpbWU9MTQxNTM0MzcxNSZub25jZT0wLjY2MTQ1MDA1MDgzNTE0MjMmZXhwaXJlX3RpbWU9MTQxNzkzNTY4NQ=="
    let subscribeToSelf = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initMeteor()
        self.tapGestureRecognizer = UITapGestureRecognizer()
        
        self.session = OTSession(apiKey: APIKey, sessionId: SessionID, delegate: self)
        self.doConnect()
    }
    
    func initMeteor() {
//        self.meteorClient.addSubscription("taps")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportConnection", name: MeteorClientDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportDisconnection", name: MeteorClientDidDisconnectNotification, object: nil)
    }
    
    func reportConnection() {
        println("================> connected to server!")
    }
    
    func reportDisconnection() {
        println("================> disconnected from server!")
    }
    
    func doConnect() {
        var error : OTError? = nil
        
        self.session.connectWithToken(Token, error: &error)
        if (error != nil) {
            // self.showAlert
        }
        
    }
    
    func doPublish() {
        self.publisher = OTPublisher(delegate: self, name: UIDevice.currentDevice().name)

        var error : OTError? = nil
        self.session.publish(self.publisher, error: &error)
        if (error != nil) {
            // self.showAlert
        }
        
        // self.view.addSubview(self.publisher.view!)
        // self.publisher.view.frame = CGRectMake(0, 0, 320, 240)
    }
    
    func cleanupPublisher() {
        self.publisher.view.removeFromSuperview()
        // self.publisher = nil
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
    
    // OTSession Delegate Callbacks
    
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
    
    // OTSubscriber delegate callbacks
    
    func subscriberDidConnectToStream(subscriber: OTSubscriberKit!) {
        println("subscriberDidConnectToStream \(subscriber.stream.connection.connectionId)")
        assert(subscriber == self.subscriber)
        self.subscriber.view.frame = CGRectMake(0, 20, 320, 460)
        self.view.addSubview(self.subscriber.view)
    }
    
    func subscriber(subscriber: OTSubscriberKit!, didFailWithError error: OTError!) {
        println("")
    }
    
    // OTPublisher delegate callbacks
    
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
        println("")
        self.cleanupPublisher()
    }
    
    func showAlert(string: String) {
//        dispatch_async(dispatch_get_main_queue(), {
//            var alert : UIAlertView = UIAlertView(title: "OTError", message: string, delegate: self, cancelButtonTitle: "OK", otherButtonTitles: nil)
//            }, alert.show())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touch: AnyObject? = event.allTouches()?.anyObject()
        var touchPoint = touch?.locationInView(self.view)
        
        var xcor = touchPoint?.x
        var ycor = touchPoint?.y

        var tapData = ["x": Float(xcor!), "y": Float(ycor!)]
        
        self.meteorClient.callMethodName("createTap", parameters: [tapData], responseCallback: nil)
        
        println("x: \(touchPoint?.x)")
        println("y: \(touchPoint?.y)")
    }
}


