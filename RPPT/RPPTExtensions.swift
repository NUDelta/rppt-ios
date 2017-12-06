//
//  RPPTExtensions.swift
//  RPPT
//
//  Created by Andrew Finke on 12/5/17.
//  Copyright © 2017 aspin. All rights reserved.
//

import Foundation

extension CGPoint {
    static public func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
}
