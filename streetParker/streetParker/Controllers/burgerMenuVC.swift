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

class burgerMenuVC: UIViewController, LoginButtonDelegate{
    
    
    //, LoginButtonDelegate 
    
    @IBOutlet weak var nameLbl: UIButton!
    
    @IBOutlet weak var profileImage: UIButton!
    
    @IBOutlet weak var signOutBTN: UIButton!
    
    var email: String?
    var id: String?
    var name: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        //EXC_BREAKPOINT (code=1, subcode=0x102b452ac)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if Auth.auth().currentUser != nil {
//            signOutBTN.setTitle("Logout", for: .normal)
//        }
//
        
        signOutBTN.layer.cornerRadius = 10
        if let token = AccessToken.current,!token.isExpired {
            signOutBTN.isHidden = true
            let FBButton = FBLoginButton()
            FBButton.frame = CGRect(x: 25, y: 600, width: 200, height: 40)
            nameLbl.setTitle(name, for: .normal)
            view.addSubview(FBButton)
            FBButton.delegate = self
        } else {
            signOutBTN.isHidden = false
            signOutBTN.setTitle("Logout", for: .normal)
        }
        
        print(Auth.auth().currentUser?.uid)
    }

    @IBAction func signOutWasPressed(_ sender: Any) {
        Authservice.instance.signOut()
        
        if Auth.auth().currentUser != nil {
            Authservice.instance.signOut()
        }
        
        if #available(iOS 13.0, *) {
            print("Logged Out")
            let authVC = storyboard?.instantiateViewController(identifier: "AuthVC") as? AuthVC
            authVC?.modalPresentationStyle = .fullScreen
            self.present(authVC!, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @IBAction func profileImageTapped(_ sender: Any) {
        
    }
    
//    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
//        print("Nothing")
//    }
//
//    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
//        print("x")
//        if #available(iOS 13.0, *) {
//            let AuthVC = storyboard?.instantiateViewController(identifier: "AuthVC") as? AuthVC
//            self.present(AuthVC!, animated: true, completion: nil)
//        } else {
//            // Fallback on earlier versions
//        }
//
//    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        print("LoginMenuVC LOgged in")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("FB User logged out")
        Authservice.instance.signOut()
        
        if #available(iOS 13.0, *) {
            let authVC = storyboard?.instantiateViewController(identifier: "AuthVC") as? AuthVC
            authVC?.modalPresentationStyle = .fullScreen
            self.present(authVC!, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
}


