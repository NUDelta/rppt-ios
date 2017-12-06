//
//  RPPTController+Session.swift
//  RPPT
//
//  Created by Andrew Finke on 12/5/17.
//  Copyright © 2017 aspin. All rights reserved.
//

import UIKit

extension RPPTClient {

    // MARK: - RPPTSessionManager

    // TODO: CHECK THREADS
    func setupSessionManager() {
        sessionManager.onSubscriberConnected = { subscriberView in
            self.onSubscriberConnected?(subscriberView)
        }

        sessionManager.onSessionError = { error in
            self.onOpenTokError?(error)
        }

        sessionManager.onPublisherError = { error in
            self.onOpenTokError?(error)
        }

        sessionManager.onSubscriberError = { error, view in
            view?.removeFromSuperview()
            if let error = error {
                self.onOpenTokError?(error)
            }
        }

    }

}
