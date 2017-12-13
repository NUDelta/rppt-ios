//
//  RPPTAppDelegate.swift
//  RPPT
//
//  Created by Kevin Chen on 10/3/14.
//  Copyright (c) 2014 aspin. All rights reserved.
//

import UIKit

@UIApplicationMain
class RPPTAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func applicationDidFinishLaunching(_ application: UIApplication) {
        if UserDefaults.standard.bool(forKey: "SetupComplete") {
            RPPTClient.shared.connectWebSocket()
        }
    }
}
