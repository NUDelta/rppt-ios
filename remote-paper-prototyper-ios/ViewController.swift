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

    var session : OTSession!
    var publisher: OTPublisher!
    var subscriber: OTSubscriber!
    var tapGestureRecognizer : UITapGestureRecognizer!
    
    let height = 240
    let width = 320
    
    let APIKey = "45040222"
    let SessionID = "1_MX40NTA0MDIyMn5-MTQxNDA5NTYxNjEyMH5maGZKSVREODc0MkM0K0MvR3kvLzgrQ2l-fg"
    let Token = "T1==cGFydG5lcl9pZD00NTA0MDIyMiZzaWc9Y2VjNDhiZWNlNTQ1ODE0MTczMWI2NTQ5YTY0MjVhNzZmMGY2OTYyMTpyb2xlPXN1YnNjcmliZXImc2Vzc2lvbl9pZD0xX01YNDBOVEEwTURJeU1uNS1NVFF4TkRBNU5UWXhOakV5TUg1bWFHWktTVlJFT0RjME1rTTBLME12UjNrdkx6Z3JRMmwtZmcmY3JlYXRlX3RpbWU9MTQxNDA5NTY5MSZub25jZT0wLjU2NzUyNjI3MjA4ODk1NjEmZXhwaXJlX3RpbWU9MTQxNDcwMDQxMA=="
    let subscribeToSelf = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tapGestureRecognizer = UITapGestureRecognizer()
        self.session = OTSession(apiKey: APIKey, sessionId: SessionID, delegate: self)
        self.doConnect()
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
    
//    override func viewDidAppear(animated: Bool) {
//        // live stream viewer
////         let fileURL = NSURL.URLWithString("http://glass.ci.northwestern.edu:4000/vod/mp4:sample.mp4/playlist.m3u8")
//        
////        let filePath = NSBundle.mainBundle().pathForResource("demoVideo", ofType: "mp4")
////        let fileURL = NSURL.fileURLWithPath(filePath!)
//        
//        self.videoController.contentURL = fileURL
//        self.videoController.view.frame = CGRectMake(0, 0, 320,460)
//        self.videoController.controlStyle = MPMovieControlStyle.None
//        self.view.addSubview(self.videoController.view)
//        self.videoController.play()
//
//    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touch = event.allTouches()?.anyObject()
        var touchPoint = touch?.locationInView(self.view)
        println("x: \(touchPoint?.x)")
        println("y: \(touchPoint?.y)")
    }
}


