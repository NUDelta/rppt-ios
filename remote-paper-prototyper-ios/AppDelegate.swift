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

        // If connected, make sure screen doesn't turn off
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func reportConnectionReady() {
        print("================> server connection ready!")
    }
    
    func reportDisconnection() {
        print("================> disconnected from server!")

        // If disconnected, make sure screens can turn off so battery isn't wasted.
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

