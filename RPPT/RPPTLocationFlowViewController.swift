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

    // MARK: - Properties

    private let locationManager = CLLocationManager()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        titleText = "Location Access"
        descriptionText = "McGonagall needs your location for the wizard to see where you are."
        continueText = "Enable"

        image = #imageLiteral(resourceName: "Map")
    }

    override func continueButtonPressed() {
        if CLLocationManager.authorizationStatus() == .denied {
            let title = "Location Required"
            //swiftlint:disable:next line_length
            let message = "Your location is required to setup McGonagall. Please open settings to enable location access."
            presentAlert(title: title, message: message)
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            let flowVC = RPPTCameraFlowViewController()
            navigationController?.pushViewController(flowVC, animated: true)
        } else {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            let title = "Location Restricted"
            //swiftlint:disable:next line_length
            let message = "Your device's ability to grant location authorization is restricted."
            presentAlert(title: title, message: message)
        case .denied:
            let title = "Location Required"
            //swiftlint:disable:next line_length
            let message = "Your location is required to setup McGonagall. Please open settings to enable location access."
            presentAlert(title: title, message: message)
        case .authorizedWhenInUse:
            let flowVC = RPPTCameraFlowViewController()
            navigationController?.pushViewController(flowVC, animated: true)
        default:
            fatalError()
        }
    }
}
