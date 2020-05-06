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
    
    func uploadLocation(){
        
    }
    
    func printAllEmails(forEmail emaill: String, handler: @escaping (_ emailArray: [String]) -> ()){
        
        var emailArray = [String]()
        REF_USERS.observe(.value) { (userSnapShot) in
            // we gonna watch all the user
            
            guard let userSnapshot = userSnapShot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as! String
                emailArray.append(email)
            }
            handler(emailArray)
        }
    }
    
    func getNameForEmail(forEmail em: String, handler: @escaping (_ name: String) -> ()){
        
        var name = String()
        REF_USERS.observe(.value) { (userSnapShot) in
            // we gonna watch all the user
            
            guard let userSnapshot = userSnapShot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as! String
                if em == email {
                    if(user.hasChild("Name")){
                        let FIreName = user.childSnapshot(forPath: "Name").value as! String
                        name = FIreName
                        handler(name)
                    }else{
                        name = "\((Auth.auth().currentUser?.email)!)"
                        handler(name)
                    }
                    
                    
                }
            }
            
        }
    }
}

