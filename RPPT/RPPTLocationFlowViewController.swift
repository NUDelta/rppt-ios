//
//  RPPTLocationFlowViewController.swift
//  RPPTFlow
//
//  Created by Andrew Finke on 12/10/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import UIKit
import CoreLocation

class RPPTLocationFlowViewController: RPPTFlowViewController, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        titleText = "Location Access"
        descriptionText = "McGonagall needs your location for the wizard to see where you are."
        continueText = "Enable"

        image = #imageLiteral(resourceName: "Map")
    }

    override func continueButtonPressed() {
        if CLLocationManager.authorizationStatus() == .denied {
            presentAlert(title: "Location Required", message: "Your location is required to setup McGonagall. Please open settings to enable location access.")
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            navigationController?.pushViewController(RPPTCameraFlowViewController(), animated: true)
        } else {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            presentAlert(title: "Location Restricted",
                         message: "Your device's ability to grant location authorization is restricted.")
        case .denied:
            presentAlert(title: "Location Required",
                         message: "Your location is required to setup McGonagall. Please open settings to enable location access.")
        case .authorizedWhenInUse:
            navigationController?.pushViewController(RPPTCameraFlowViewController(),
                                                     animated: true)
        default:
            fatalError()
        }
    }
}
