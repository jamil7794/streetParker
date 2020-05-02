//
//  burgerMenuVC.swift
//  streetParker
//
//  Created by Jamil Jalal on 11/18/19.
//  Copyright © 2019 Jamil Jalal. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class burgerMenuVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if Auth.auth().currentUser != nil {
            let FBButton = FBLoginButton()
            FBButton.center = view.center
            view.addSubview(FBButton)
        //}
       
    }
    

    @IBAction func signOutWasPressed(_ sender: Any) {
        Authservice.instance.signOut()
        if #available(iOS 13.0, *) {
            print("Logged Out")
            let AuthVC = storyboard?.instantiateViewController(identifier: "AuthVC") as? AuthVC
            self.present(AuthVC!, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
}


