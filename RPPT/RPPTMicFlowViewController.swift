//
//  RPPTMicFlowViewController.swift
//  RPPT
//
//  Created by Andrew Finke on 12/12/17.
//  Copyright © 2017 aspin. All rights reserved.
//

import UIKit
import AVFoundation

class RPPTMicFlowViewController: RPPTFlowViewController {

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        titleText = "Microphone Access"
        descriptionText = "McGonagall needs microphone access so the wizard can hear your thoughts."
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
        let title = "Microphone Access Required"
        let message = "Microphone access  is required to setup McGonagall. Please open settings to enable microphone access."
        AVCaptureDevice.requestAccess(for: .audio) { success in
            DispatchQueue.main.async {
                if success {
                    let flowVC = RPPTFinalFlowViewController()
                    self.navigationController?.pushViewController(flowVC, animated: true)
                } else {
                    self.presentAlert(title: title, message: message)
                }
            }

        }
    }

}
