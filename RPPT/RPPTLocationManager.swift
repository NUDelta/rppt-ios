//
//  RPPTLocationManager.swift
//  RPPT
//
//  Created by Andrew Finke on 12/5/17.
//  Copyright © 2017 aspin. All rights reserved.
//

import CoreLocation

class RPPTLocationManager: NSObject, CLLocationManagerDelegate {

    // MARK: - Properties

    private let manager = CLLocationManager()

    public var onError: ((Error) -> Void)?
    public var onUpdate: ((CLLocationCoordinate2D) -> Void)?

    // MARK: - Initialization

    public override init() {
        super.init()

        manager.delegate = self
        manager.distanceFilter = kCLDistanceFilterNone
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.requestWhenInUseAuthorization()
    }

    public func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("RPPTLocationManager: " + #function + " Error: " + error.localizedDescription)
        onError?(error)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        onUpdate?(coordinate)
    }

}
