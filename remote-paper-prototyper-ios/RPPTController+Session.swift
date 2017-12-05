//
//  RPPTController+Session.swift
//  RPPT
//
//  Created by Andrew Finke on 12/5/17.
//  Copyright © 2017 aspin. All rights reserved.
//

import UIKit

extension RPPTController {

    // MARK: - RPPTSessionManager

    // TODO: CHECK THREADS
    func setupSessionManager() {

        sessionManager.onSubscriberConnected = { subscriberView in
            let screenRect = UIScreen.main.bounds
            subscriberView.frame = CGRect(x: 0, y: 20, width: screenRect.width, height: screenRect.width * 1.4375)
            self.view.addSubview(subscriberView)
            self.view.bringSubview(toFront: self.stopButton)
        }

        sessionManager.onSessionError = { error in
            self.showAlertWithMessage(title: "Session Error", message: error.localizedDescription)
        }

        sessionManager.onPublisherError = { error in
            self.showAlertWithMessage(title: "Session Error", message: error.localizedDescription)
        }

        sessionManager.onSubscriberError = { error, view in
            view?.removeFromSuperview()
            self.showAlertWithMessage(title: "Session Error", message: error.localizedDescription)
        }

    }
    
}
