//
//  RPPTController+Location.swift
//  RPPT
//
//  Created by Andrew Finke on 12/5/17.
//  Copyright © 2017 aspin. All rights reserved.
//

import MapKit

extension RPPTClient {

    // MARK: - RPPTLocationManager

    func setupLocationManager() {

        locationManager.onError = { error in
            print(error.localizedDescription)
        }

        locationManager.onUpdate = { coordinate in
            guard let syncCode = self.syncCode else { return }

            let params: [String: Any] = [
                "lat": coordinate.latitude,
                "lng": coordinate.longitude,
                "session": syncCode
            ]

            self.client.callMethodName("/locations/insert",
                                        parameters: [params] ,
                                        responseCallback: nil)

//            // hardcoded mapSpan could eventually become a wizard input
//            let mapSpan = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
//            let mapCoordinateRegion = MKCoordinateRegion(center: coordinate, span: mapSpan)
//            self.mapView.region = mapCoordinateRegion
        }

    }

}
