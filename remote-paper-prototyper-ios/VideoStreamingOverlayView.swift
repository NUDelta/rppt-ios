//
//  VideoStreamingOverlayView.swift
//  RPPT
//
//  Created by Meg Grasse on 10/4/16.
//  Copyright © 2016 aspin. All rights reserved.
//

import UIKit

class VideoStreamingOverlayView: UIView, UIKeyInput {

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var hasText: Bool = true;
    
    func insertText(_ text: String) {
        // Do something with the typed character
    }
    
    func deleteBackward() {
    // Handle the delete key
    }
}
