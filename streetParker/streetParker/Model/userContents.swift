//
//  userContents.swift
//  streetParker
//
//  Created by Jamil Jalal on 5/3/20.
//  Copyright © 2020 Jamil Jalal. All rights reserved.
//

import Foundation

class userContents {
    
    private var _name: String = ""
    private var _email: String = ""

    var name: String {
        return _name
    }

    var email: String {
        return _email
    }

    func setData(name: String, email: String) {
        self._name = name
        self._email = email
    }
    
    
}
