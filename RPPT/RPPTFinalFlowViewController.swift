//
//  RPPTFinalFlowViewController.swift
//  RPPTFlow
//
//  Created by Andrew Finke on 12/10/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import UIKit

class RPPTFinalFlowViewController: RPPTFlowViewController {

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        titleText = "Setup Complete!"
        descriptionText = "Your device is now ready to use McGonagall."
        continueText = "Start"

        isCancelButtonHidden = true

        let placeholderLabel = UILabel()
        placeholderLabel.numberOfLines = 0
        placeholderLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        placeholderLabel.text = "Maybe basic steps on how to enter pin?"
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
        RPPTClient.shared.connectWebSocket()
        UserDefaults.standard.set(true, forKey: "SetupComplete")
        navigationController?.dismiss(animated: true, completion: nil)
    }

}
