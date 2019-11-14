//
//  Dataservice.swift
//  streetParker
//
//  Created by Jamil Jalal on 11/14/19.
//  Copyright © 2019 Jamil Jalal. All rights reserved.
//

import Foundation
import Firebase
let DB_BASE = Database.database().reference()

class Dataservice{
    static let instance = Dataservice()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_CHAT = DB_BASE.child("chat")
    
    var REF_BASE : DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS : DatabaseReference {
        return _REF_USERS
    }
    
    var REF_CHAT : DatabaseReference {
        return _REF_CHAT
    }
    
    func createDBUser(uid: String, userData: Dictionary<String,Any>){
        REF_USERS.child(uid).updateChildValues(userData)
    }
}
