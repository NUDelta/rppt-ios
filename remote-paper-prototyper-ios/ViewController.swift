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

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var videoController : MPMoviePlayerController!
    var tapGestureRecognizer : UITapGestureRecognizer!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.videoController = MPMoviePlayerController()
        self.tapGestureRecognizer = UITapGestureRecognizer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        let filePath = NSBundle.mainBundle().pathForResource("demoVideo", ofType: "mp4")
        let fileURL = NSURL.fileURLWithPath(filePath!)
        
        self.videoController.contentURL = fileURL
        self.videoController.view.frame = CGRectMake(0, 0, 320,460)
        self.videoController.controlStyle = MPMovieControlStyle.None
        self.view.addSubview(self.videoController.view)
        self.videoController.play()

    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touch = event.allTouches()?.anyObject()
        var touchPoint = touch?.locationInView(self.view)
        println("x: \(touchPoint?.x)")
        println("y: \(touchPoint?.y)")
    }
}


