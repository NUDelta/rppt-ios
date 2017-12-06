//
//  ViewController.swift
//  remote-paper-prototyper-ios
//
//  Created by Kevin Chen on 10/3/14.
//  Copyright (c) 2014 aspin. All rights reserved.
//

import UIKit
import MobileCoreServices
import MapKit

class RPPTController: UIViewController {
    
    // MARK: - IB Interface Elements

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var reSyncButton: UIButton!

    // MARK: - Other Interface Elements

    let mapView = MKMapView()

    let textView = UITextView()
    let imageView = UIImageView()
    let overlayedImageView = UIImageView()

    let picker = UIImagePickerController()

    // MARK: - Properties

    let client = RPPTClient()

    var task: RPPTTask?
    var capturer: ScreenCapturer!

    var lastX = Float(0)
    var lastY = Float(0)

    var photoArray = [UIImage]()

    // I hate myself (don't we all)
    var pickerIsVisible = false;

    // Gesture Recognition Members
    var tapGestureRecognizer: UITapGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tapGestureRecognizer = UITapGestureRecognizer()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(RPPTController.handlePan))

        view.addGestureRecognizer(panGestureRecognizer)
        
        textView.delegate = self
        textView.backgroundColor = UIColor.clear

        setUpCamera()
        setupClient()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !client.isConnected {
            showSyncCodeAlert()
        }
    }

    private func setupClient() {
        client.onTaskUpdated = { task in
            self.task = task
        }

        client.onClientError = { error in

        }

        client.onOpenTokError = { error in

        }

        client.onSubscriberConnected = { subscriberView in
            let screenRect = UIScreen.main.bounds
            subscriberView.frame = CGRect(x: 0, y: 20, width: screenRect.width, height: screenRect.width * 1.4375)
            self.view.addSubview(subscriberView)
            self.view.bringSubview(toFront: self.stopButton)
        }
    }
    
    func showSyncCodeAlert() {
        let alert = UIAlertController(title: "Sync", message: "Enter the sync code below", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let syncCode = (alert.textFields![0] as UITextField).text!

            NotificationCenter.default.addObserver(self, selector: #selector(self.messageChanged), name: NSNotification.Name("messages_changed"), object: nil)

            self.client.start(withSyncCode: syncCode)
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = ""
        })
        present(alert, animated: true, completion: nil)
    }
    
    func setUpCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        picker.sourceType = .camera
        picker.mediaTypes = [kUTTypeImage as String]
        picker.delegate = self
    }

    // TODO: THIS
    @objc func messageChanged(notification: NSNotification) {
        guard let result = notification.userInfo as? [String:String] else { return }

        if result["_id"] == task?.messageID && result["type"] == "task" {
            taskLabel.text = result["content"]
            AudioServicesPlaySystemSound(1003)
        }

        if result["keyboard"] == "show" {
            // Where do these numbers come from
            textView.frame = CGRect(x: 50, y: self.view.frame.height - 256, width: self.view.frame.width - 10, height: 40)
            self.view.addSubview(textView)
            self.textView.becomeFirstResponder()
        } else if result["keyboard"] == "hide" {
            self.textView.resignFirstResponder()
            self.textView.removeFromSuperview()
        }

        if result["camera"] == "show" {
            if (!pickerIsVisible) {
                self.present(picker, animated: true, completion: nil)
                pickerIsVisible = true;
            }
        } else if result["camera"] == "hide" {
            if (pickerIsVisible) {
                picker.dismiss(animated: true, completion: nil)
                pickerIsVisible = false;
            }
        }

        if let imageFullEncoding = result["overlayedFullImage"] {
            self.overlayFullImage(imageEncoding: imageFullEncoding)
        }

        if let overlayedImageXString = result["overlayedImage_x"], let overlayedImageYString = result["overlayedImage_y"], let overlayedImageHeightString = result["overlayedImage_height"], let overlayedImageWidthString = result["overlayedImage_width"], let imageEncoding = result["overlayedImage"] {
            let overlayedImageX = Double(overlayedImageXString)
            let overlayedImageY = Double(overlayedImageYString)
            let overlayedImageHeight = Double(overlayedImageHeightString)
            let overlayedImageWidth = Double(overlayedImageWidthString)
            let isCameraOverlay = (result["isCameraOverlay"] == "true") ? true : false
            if overlayedImageX != -999 && overlayedImageY != -999 && overlayedImageWidth != -999 && overlayedImageHeight != -999 {
                self.overlayImage(x: CGFloat(overlayedImageX!), y: CGFloat(overlayedImageY!), height: CGFloat(overlayedImageHeight!), width: CGFloat(overlayedImageWidth!), imageEncoding: imageEncoding, isCameraOverlay: isCameraOverlay)
            }
        }

        if let mapXString = result["map_x"], let mapYString = result["map_y"], let mapWidthString = result["map_width"], let mapHeightString = result["map_height"] {
            let mapX = Double(mapXString)
            let mapY = Double(mapYString)
            let mapHeight = Double(mapHeightString)
            let mapWidth = Double(mapWidthString)
            if mapX != -999 && mapY != -999 && mapWidth != -999 && mapHeight != -999 {
                mapView.frame = CGRect(x: CGFloat(mapX!), y: CGFloat(mapY!), width: CGFloat(mapWidth!), height: CGFloat(mapHeight!))
                if overlayedImageView.isDescendant(of: self.view) {
                    self.view.insertSubview(mapView, belowSubview: overlayedImageView)
                } else {
                    self.view.addSubview(mapView)
                }
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
                if (photoArray.count != 0) {
                    imageView.frame = CGRect(x: CGFloat(photoX!), y: CGFloat(photoY!), width: CGFloat(photoWidth!), height: CGFloat(photoHeight!))
                    imageView.image = photoArray.last!
                    if overlayedImageView.isDescendant(of: self.view) {
                        self.view.insertSubview(imageView, belowSubview: overlayedImageView)
                    } else {
                        self.view.addSubview(imageView)
                    }
                }
            } else {
                self.imageView.removeFromSuperview()
            }
        }
    }

    func overlayFullImage(imageEncoding: String) {
        let dataDecoded = Data(base64Encoded: imageEncoding, options: .ignoreUnknownCharacters)
        let decodedimage = UIImage(data: dataDecoded!)
//        overlayedImageView.frame = (subscriber.view?.frame)!
        overlayedImageView.image = decodedimage
        self.view.addSubview(overlayedImageView)
        self.view.bringSubview(toFront: overlayedImageView)
    }
    
    func overlayImage(x: CGFloat, y: CGFloat, height: CGFloat, width: CGFloat, imageEncoding: String, isCameraOverlay: Bool) {
        let dataDecoded = Data(base64Encoded: imageEncoding, options: .ignoreUnknownCharacters)
        let decodedimage = UIImage(data: dataDecoded!)
        overlayedImageView.image = decodedimage
        overlayedImageView.frame = CGRect(x: x, y: y, width: width, height: height)
        if (isCameraOverlay) {
            picker.showsCameraControls = false
            picker.cameraOverlayView = overlayedImageView
        } else {
            self.view.addSubview(overlayedImageView)
            self.view.bringSubview(toFront: overlayedImageView)
        }
    }
    
    func sendMessage() {
        client.sendMessage(text: textView.text)
    }
    
    func resetStreams() {
        //To fix
        // TODO: I GUESS FIX??
//        if let sess = subscribingSession {
//            var error : OTError? = nil
//            sess.disconnect(&error)
//            subscriber.view?.removeFromSuperview()
//
//        }
    }
    
    @IBAction func stopButtonTapped(sender: AnyObject) {
        resetStreams()
    }
    
    @IBAction func resyncButtonTapped(sender: AnyObject) {
        resetStreams()
        showSyncCodeAlert()
    }
    
    func showAlertWithMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject? = event!.allTouches?.first
        let touchPoint = touch?.location(in: self.view);
        
        lastX = Float((touchPoint?.x)!)
        lastY = Float((touchPoint?.y)!)
        sendTap(x: self.lastX, y: self.lastY)
    }
    
    @objc func handlePan(pan: UIPanGestureRecognizer) {
        let motion = pan.translation(in: self.view)
        sendTap(x: lastX + Float(motion.x), y: lastY + Float(motion.y))
    }
    
    func sendTap(x: Float, y: Float) {
        let (scaledX, scaledY) = scale(x: x, y: y)
        if scaledY < 500 {
            client.createTap(scaledX: scaledX, scaledY: scaledY)
        }
    }
    
    func scale(x: Float, y: Float) -> (Float, Float) {
        let screenRect = UIScreen.main.bounds,
            scaledX = x * 320 / Float(screenRect.width),
            scaledY = y * 460 / Float(screenRect.width * 1.4375)
        return (scaledX, scaledY)
    }

}

extension RPPTController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - UIImagePickerController Delegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        photoArray.append(info[UIImagePickerControllerOriginalImage] as! UIImage)
        picker.dismiss(animated: true, completion: nil)
    }
}

extension RPPTController: UITextViewDelegate {

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        guard textView.text.last == "\n" else { return }

        sendMessage()
        textView.text = ""
    }
}


