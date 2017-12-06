//
//  RPPTClient.swift
//  RPPT
//
//  Created by Andrew Finke on 12/5/17.
//  Copyright © 2017 aspin. All rights reserved.
//

import Foundation

class RPPTClient {

    // MARK: - Closures

    var onSubscriberConnected: ((UIView) -> Void)?
    var onTaskUpdated: ((RPPTTask) -> Void)?

    var onClientError: ((Error?) -> Void)?
    var onOpenTokError: ((Error) -> Void)?

    // MARK: - Properties

    let client: MeteorClient
    let sessionManager = RPPTSessionManager()
    let locationManager = RPPTLocationManager()

    private(set) var syncCode: String?
    var isConnected: Bool {
        return sessionManager.isConnected
    }

    // MARK: - Initialization

    init() {
        let version = "1"
        let endpoint = "ws://rppt.meteorapp.com/websocket"

        client = MeteorClient(ddpVersion: version)
        client.ddp = ObjectiveDDP(urlString: endpoint, delegate: client)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reportConnection),
                                               name: NSNotification.Name.MeteorClientDidConnect,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reportConnectionReady),
                                               name: NSNotification.Name.MeteorClientConnectionReady,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reportDisconnection),
                                               name: NSNotification.Name.MeteorClientDidDisconnect,
                                               object: nil)

        setupSessionManager()
        setupLocationManager()
    }

    func connectWebSocket() {
        client.ddp.connectWebSocket()
    }

    func start(withSyncCode syncCode: String) {
        self.syncCode = syncCode

        client.addSubscription("messages", withParameters: [syncCode])

        client.callMethodName("getTaskId", parameters: [syncCode]) { response, error in
            if let error = error {
                self.onClientError?(error)
            } else if let result = response?["result"] as? [String: String],
                let content = result["content"],
                let id = result["_id"] {
                self.onTaskUpdated?(RPPTTask(content: content, messageID: id))
            }
        }

        let subscriberParams: [Any] = [syncCode, "subscriber"]
        client.callMethodName("getStreamData", parameters: subscriberParams) { response, error in
            if let error = error {
                self.onOpenTokError?(error)
            } else if let result = response?["result"] as? [String: String] {
                self.sessionManager.connect(withProperties: result, asPublisher: false, completion: { error in
                    print("Failed to connect with error: \(String(describing: error))")
                })
                self.locationManager.startUpdatingLocation()
            } else {
                self.onClientError?(nil)
            }
        }

        let publisherParams: [Any] = [syncCode, "publisher"]
        client.callMethodName("getStreamData", parameters: publisherParams) { response, error in
            if let error = error {
                self.onOpenTokError?(error)
            } else if let result = response?["result"] as? [String: String] {
                self.sessionManager.connect(withProperties: result, asPublisher: true, completion: { error in
                    print("Failed to connect with error: \(String(describing: error))")
                })
            }
        }
    }

    // MARK: - Helpers

    func sendMessage(text: String) {
        guard let syncCode = syncCode else { return }
        let parameters: [Any] = [syncCode, text]

        client.callMethodName("printKeyboardMessage",
                              parameters: parameters,
                              responseCallback: nil)
    }

    func createTap(scaledX: CGFloat, scaledY: CGFloat) {
        guard let syncCode = syncCode else { return }
        let parameters: [Any] = [syncCode, scaledX, scaledY]

        client.callMethodName("createTap",
                              parameters: parameters,
                              responseCallback: nil)
    }

    // MARK: - Notifications

    @objc
    func reportConnection() {
        print("RPPTClient: " + #function)
        UIApplication.shared.isIdleTimerDisabled = true
    }

    @objc
    func reportConnectionReady() {
        print("RPPTClient: " + #function)
    }

    @objc
    func reportDisconnection() {
        print("RPPTClient: " + #function)
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
