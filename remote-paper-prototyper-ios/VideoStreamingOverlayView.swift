//
//  VideoStreamingOverlayView.swift
//  RPPT
//
//  Created by Meg Grasse on 10/4/16.
//  Copyright © 2016 aspin. All rights reserved.
//

import UIKit

class VideoStreamingOverlayView: UIView, UIKeyInput {
    
    var message = ""
    
    var meteorClient = (UIApplication.shared.delegate as! AppDelegate).meteorClient

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var hasText: Bool = true;
    
    func insertText(_ text: String) {
        if (text == "\n") {
            sendMessage()
        }
        message += text
    }
    
    func deleteBackward() {
        message = message.substring(with: message.startIndex..<message.index(message.endIndex, offsetBy: -1))
    }
    
    func sendMessage() {
        print(((UIApplication.shared.delegate as! AppDelegate).syncCode)!)
        print(message)
        (UIApplication.shared.delegate as! AppDelegate).meteorClient.callMethodName("printKeyboardMessage", parameters: [((UIApplication.shared.delegate as! AppDelegate).syncCode!), message], responseCallback: nil)
    }

}
