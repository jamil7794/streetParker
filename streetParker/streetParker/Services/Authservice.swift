//
//  Authservice.swift
//  streetParker
//
//  Created by Jamil Jalal on 11/15/19.
//  Copyright © 2019 Jamil Jalal. All rights reserved.
//

import Foundation
import Firebase

class Authservice {
    static let instance = Authservice()
    
    func registerUser(withEmail email: String, andPassword password: String, userCreationComplete: @escaping (_ status: Bool, _ error: Error?) -> ()){
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard let user = user else {
                userCreationComplete(false, error)
                return
            }
            
            let userData = ["provider": user.user.providerID, "email": user.user.email]
            Dataservice.instance.createDBUser(uid: user.user.uid, userData: userData)
            userCreationComplete(true,nil)
        }
    }
    
    func loginUser(withEmail email: String, andPassword password: String, loginComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                loginComplete(false, error)
                return
            }
            loginComplete(true,nil)
        }
        
    }
}
