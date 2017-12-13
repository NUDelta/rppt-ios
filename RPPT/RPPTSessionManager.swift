//
//  RPPTSessionManager.swift
//  RPPT
//
//  Created by Andrew Finke on 12/5/17.
//  Copyright © 2017 aspin. All rights reserved.
//

import UIKit

class RPPTSessionManager: NSObject, OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherKitDelegate {

    // MARK: - Closures

    var onSubscriberConnected: ((UIView) -> Void)?

    var onSessionError: ((Error) -> Void)?
    var onPublisherError: ((Error) -> Void)?
    var onSubscriberError: ((Error?, UIView?) -> Void)?

    // MARK: - Properties

    private var publishingSession: OTSession?
    private var subscribingSession: OTSession?

    private var publisherKit: OTPublisherKit?
    private var subscriber: OTSubscriber?

    var isConnected: Bool {
        return subscribingSession != nil && publishingSession != nil
    }

    // TODO: DOES THIS BLOCK MAIN THREAD (ASSUMING YES) SHOULD CHANGE
    func connect(withProperties properties: RPPTSessionProperties,
                 completion: ((Error?) -> Void)) {
        print("RPPTSessionManager: " + #function)

        guard let session = OTSession(apiKey: properties.apiKey,
                                      sessionId: properties.streamId,
                                      delegate: self) else {
                fatalError("Failed to create session with properties: \(properties)")
        }

        if properties.isPublisher {
            publishingSession = session
        } else {
            subscribingSession = session
        }

        var error: OTError? = nil
        session.connect(withToken: properties.token, error: &error)
        completion(error)
    }

    // MARK: - Helpers

    private func publish(_ session: OTSession) {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name

        publisherKit = OTPublisherKit(delegate: self, settings: settings)
        publisherKit?.videoType = .screen
        publisherKit?.audioFallbackEnabled = false
        publisherKit?.videoCapture = RPPTScreenCapturer()

        guard let publishingSession = publishingSession,
            let publisherKit = publisherKit else {
            fatalError("Attempted to publish with nil publishingSession")
        }

        var error: OTError? = nil
        publishingSession.publish(publisherKit, error: &error)
        if let error = error {
            onPublisherError?(error)
        }
    }

    func subscribe(to stream: OTStream) {
        subscriber = OTSubscriber(stream: stream, delegate: self)

        guard let subscribingSession = subscribingSession,
            let subscriber = subscriber else {
            fatalError("Attempted to subscriber with nil subscribingSession")
        }

        var error: OTError? = nil
        subscribingSession.subscribe(subscriber, error: &error)
        if let error = error {
            onSubscriberError?(error, self.subscriber?.view)
        }
    }

    private func removePublisher() {
        publisherKit = nil
    }

    private func removeSubscriber(error: Error? = nil) {
        let view = subscriber?.view
        subscriber = nil
        onSubscriberError?(error, view)
    }

    // MARK: - OTSessionDelegate

    func sessionDidConnect(_ session: OTSession) {
        print("RPPTSessionManager: " + #function + " ID: " + session.sessionId)
        if session.capabilities?.canPublish ?? false {
            publish(session)
        }
    }

    func sessionDidDisconnect(_ session: OTSession) {
        print("RPPTSessionManager: " + #function + " ID: " + session.sessionId)
    }

    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("RPPTSessionManager: " + #function + " ID: " + session.sessionId)
        onSessionError?(error)
    }

    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("RPPTSessionManager: " + #function + " ID: " + session.sessionId)
        subscribe(to: stream)
    }

    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("RPPTSessionManager: " + #function + " ID: " + session.sessionId)
        if subscriber?.stream?.streamId == stream.streamId {
            removeSubscriber()
        } else {
            removePublisher()
        }
    }

    func session(_ session: OTSession, connectionCreated connection: OTConnection) {
        print("RPPTSessionManager: " + #function + " ID: " + session.sessionId)
    }

    // TODO: IS THIS REDUNDENT? (STREAM DESTROYED ABOVE)
    func session(_ session: OTSession, connectionDestroyed connection: OTConnection) {
        print("RPPTSessionManager: " + #function + " ID: " + session.sessionId)
        if subscriber?.stream?.connection.connectionId == connection.connectionId {
            removeSubscriber()
        } else if publisherKit?.stream?.connection.connectionId == connection.connectionId {
            removePublisher()
        } else {
            print("Jeepers! What do we have here...")
        }
    }

    // MARK: - OTPublisherKitDelegate

    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        print("RPPTSessionManager: " + #function + " ID: " + stream.streamId)
    }

    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        print("RPPTSessionManager: " + #function + " ID: " + stream.streamId)
        removePublisher()
    }

    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("RPPTSessionManager: " + #function + " Error: " + error.localizedDescription)
        onPublisherError?(error)
    }

    // MARK: - OTSubscriberKitDelegate

    func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        guard subscriber == self.subscriber,
            let view = self.subscriber?.view,
            let connectionId = subscriber.stream?.connection.connectionId else {
            fatalError("Oh boy I done goofed.")
        }
        print("RPPTSessionManager: " + #function + " ID: " + connectionId)
        onSubscriberConnected?(view)
    }

    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("RPPTSessionManager: " + #function + " Error: " + error.localizedDescription)
        removeSubscriber()
    }

}
