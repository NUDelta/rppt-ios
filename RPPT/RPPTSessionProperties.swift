//
//  RPPTSessionProperties.swift
//  RPPT
//
//  Created by Andrew Finke on 12/6/17.
//  Copyright © 2017 aspin. All rights reserved.
//

import Foundation

struct RPPTSessionProperties {

    // MARK: - Properties

    let apiKey: String
    let token: String
    let streamId: String
    let isPublisher: Bool

    // MARK: - Initialization

    init?(result: Any?, isPublisher: Bool) {
        guard let dictionary = result as? [String: String],
            let apiKey = dictionary["key"],
            let token = dictionary["token"],
            let streamId = dictionary["session"] else {
                return nil
        }
        self.apiKey = apiKey
        self.token = token
        self.streamId = streamId
        self.isPublisher = isPublisher
    }

}
