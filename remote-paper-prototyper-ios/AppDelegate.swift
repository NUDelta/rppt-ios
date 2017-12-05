//
//  AppDelegate.swift
//  remote-paper-prototyper-ios
//
//  Created by Kevin Chen on 10/3/14.
//  Copyright (c) 2014 aspin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var meteorClient: MeteorClient!
    
    let version = "1"
    let endpoint = "ws://rppt.meteorapp.com/websocket"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        meteorClient = MeteorClient.init(ddpVersion: version)
        let ddp = ObjectiveDDP.init(urlString: endpoint, delegate: meteorClient)
        meteorClient.ddp = ddp
        meteorClient.ddp.connectWebSocket()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.reportConnection), name: NSNotification.Name.MeteorClientDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.reportConnectionReady), name: NSNotification.Name.MeteorClientConnectionReady, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.reportDisconnection), name: NSNotification.Name.MeteorClientDidDisconnect, object: nil)
        
        return true
    }
    
    func reportConnection() {
        print("================> connected to server!")
    }
    
    func reportConnectionReady() {
        print("================> server connection ready!")
    }
    
    func reportDisconnection() {
        print("================> disconnected from server!")
    }

}

