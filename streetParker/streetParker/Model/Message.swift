//
//  Message.swift
//  streetParker
//
//  Created by Jamil Jalal on 11/19/19.
//  Copyright © 2019 Jamil Jalal. All rights reserved.
//

import Foundation

class Message {
    private var _content: String
    private var _senderId: String
    
    var content: String {
        return _content
    }
    
    var senderId: String {
        return _senderId
    }
    
    init(content: String, senderId: String) {
        self._content = content
        self._senderId = senderId
    }
}
