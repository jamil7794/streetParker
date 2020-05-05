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
import GoogleSignIn



class burgerMenuVC: UIViewController, LoginButtonDelegate, GIDSignInDelegate{
    
    

    
    @IBOutlet weak var nameLbl: UIButton!
    
    @IBOutlet weak var profileImage: UIButton!
    
    @IBOutlet weak var signOutBTN: UIButton!
    
    var email: String?
    var id: String?
    var name: String?
    var FBButton = FBLoginButton()
    var mainView: UIViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.delegate = self
    
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        //EXC_BREAKPOINT (code=1, subcode=0x102b452ac)
        FBButton.delegate = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if Auth.auth().currentUser != nil {
            print("Current User email in BurgerMenuVC: " + (Auth.auth().currentUser?.email)!)
        }else {
            print("Current User email in BurgerMenuVC: nil")
        }
        
        signOutBTN.layer.cornerRadius = 10
        
        
        FBButton.frame = CGRect(x: 25, y: 600, width: 200, height: 40)
        FBButton.isHidden = true
        signOutBTN.isHidden = true
    
        if let token = AccessToken.current,!token.isExpired {
            //App Crashes in burgerMenuVC because it can't connect to firebase
            Dataservice.instance.getNameForEmail(forEmail: (Auth.auth().currentUser?.email)!) { (namee) in
                print("Dataservice.instance.getNameForEmail in BurgerMenuVC:" + namee)
                self.nameLbl.setTitle(namee, for: .normal)
            }
            
            FBButton.isHidden = false
            signOutBTN.isHidden = true
            Authservice.instance.signOut()
            view.addSubview(FBButton)
            
            
        } else {
            
            print("email logged in burgerMenuVC as: " + (Auth.auth().currentUser?.email)!)
            FBButton.removeFromSuperview()
            FBButton.isHidden = true
            signOutBTN.isHidden = false
            
            Dataservice.instance.getNameForEmail(forEmail: (Auth.auth().currentUser?.email)!) { (name) in
                self.nameLbl.setTitle(name, for: .normal)
            }
            signOutBTN.setTitle("Logout", for: .normal)
        }
        
    }

    @IBAction func signOutWasPressed(_ sender: Any) {
        //Authservice.instance.signOut()
        
        if Auth.auth().currentUser != nil {
            Authservice.instance.signOut()
            print("Logged Out pressed")
        }
        
        if #available(iOS 13.0, *) {
            
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
        print("BurgerMenuVC LOgged in" + (Auth.auth().currentUser?.email)!)
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
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        
       
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
      // Perform any operations when the user disconnects from app here.
      // ...
    }
    
}


