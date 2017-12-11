//
//  RPPTScreenFlowViewController.swift
//  RPPTFlow
//
//  Created by Andrew Finke on 12/10/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import UIKit
import ReplayKit

class RPPTScreenFlowViewController: RPPTFlowViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        titleText = "Screen Capture Access"
        //swiftlint:disable next line_length
        descriptionText = "McGonagall needs to record your screen so the wizard can see what you're doing. This only records interactions inside the McGonagall app."
        continueText = "Enable"

        let placeholderLabel = UILabel()
        placeholderLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        placeholderLabel.text = "lol no idea what should go here."
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(placeholderLabel)

        let constraints = [
            placeholderLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            placeholderLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    override func continueButtonPressed() {

        func captured(success: Bool) {
            let title = "Screen Recording Required"
            let message = "Screen recording is required to setup McGonagall."
            DispatchQueue.main.async {
                if success {
                    let flowVC = RPPTFinalFlowViewController()
                    self.navigationController?.pushViewController(flowVC, animated: true)
                } else {
                    self.presentAlert(title: title, message: message)
                }
            }
        }

        #if (arch(i386) || arch(x86_64)) && os(iOS)
            captured(success: true)
            return
        #endif

        // TODO: Futher test out
        RPScreenRecorder.shared().startCapture(handler: { _, _, _ in
            RPScreenRecorder.shared().stopCapture(handler: nil)
        }) { error in
            captured(success: error == nil)
        }
    }

}
