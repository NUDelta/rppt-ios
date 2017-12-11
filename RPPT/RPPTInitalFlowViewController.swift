//
//  RPPTInitalFlowViewController.swift
//  RPPTFlow
//
//  Created by Andrew Finke on 12/10/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import UIKit

class RPPTInitalFlowViewController: RPPTFlowViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        titleText = "Welcome!"
        descriptionText = "Let's start setting up McGonagall on your device."
        continueText = "Let's Go!"
        isCancelButtonHidden = true

        image = #imageLiteral(resourceName: "delta_icon")
        navigationController?.navigationBar.tintColor = .purple
    }

    override func continueButtonPressed() {
        navigationController?.pushViewController(RPPTLocationFlowViewController(),
                                      animated: true)
    }
}
