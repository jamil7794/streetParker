//
//  ViewController.swift
//  streetParker
//
//  Created by Jamil Jalal on 11/13/19.
//  Copyright © 2019 Jamil Jalal. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import SafariServices
import GoogleSignIn
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class AuthVC: UIViewController, SFSafariViewControllerDelegate, LoginButtonDelegate, GIDSignInDelegate {
    
    
    @IBOutlet weak var activityIndication: UIActivityIndicatorView!
    

    @IBOutlet weak var googleView: UIView!
    
    @IBOutlet weak var FBView: UIView!
    
    @IBOutlet weak var viewss: UIView!
    var email =  String()
    var id: String?
    var name = String()
    //var flag = 0
    var emailLogged = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndication.startAnimating()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        // Automatically sign in the user.
        //GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        
        self.viewss.layer.cornerRadius = 15.0
        self.FBView.layer.cornerRadius = 15.0
        
        let FBButton = FBLoginButton()
        FBView.layer.cornerRadius = 15.0
        FBButton.delegate = self
        //FBButton.center = FBView.center
        FBButton.frame = CGRect(x: 0, y: 0, width: FBView.frame.width, height: FBView.frame.height)
        FBView.addSubview(FBButton)
        
        
        let googleSignInButton = GIDSignInButton(frame: CGRect(x: 0, y: 0, width: googleView.frame.width, height: googleView.frame.height))
        googleView.addSubview(googleSignInButton)
        
        
//        if let token = AccessToken.current,
//            !token.isExpired {
//            self.dismiss(animated: true, completion: nil)
//        }
//
//       if Auth.auth().currentUser != nil {
//            self.dismiss(animated: true, completion: nil)
//        }
        
        activityIndication.stopAnimating()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
//        if let token = AccessToken.current,!token.isExpired {
//            if Auth.auth().currentUser != nil {
//                print("Facbook user is already logged and in auth")
//            }else{
//                print("Facbook user is not logged in")
//                var coreDataEmail = ""
//                let randString = "FBUser" //.gitignore
////                Dataservice.instance.deleteAllDataFromCoreData { (complete) in
////                    if complete {
////
////                    }else{
////
////                    }
////                }
//                Dataservice.instance.fetchUserInfo { (em) in
//                    print("Fetched user email from core data: \(em)")
//                    coreDataEmail = em
//                }
//                Authservice.instance.loginSocialUser(withEmail: coreDataEmail, andPassword: randString) { (success, error) in
//                    if success {
//                        print("Logged in with core data email")
//
//                        //self.dismiss(animated: true, completion: nil)
//                    }else{
//                        print("Logged in with core data email error: \(error?.localizedDescription)")
//                    }
//                }
//            }
//        }

        
        if Auth.auth().currentUser != nil {
            if emailLogged == 1{
                activityIndication.stopAnimating()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    

    @IBAction func signInWithInstagram(_ sender: Any) {
        
    }
    
    @IBAction func signInWithEmail(_ sender: Any) {
        activityIndication.startAnimating()
        emailLogged = 1
        
        if #available(iOS 13.0, *) {
            let signinVC = storyboard?.instantiateViewController(withIdentifier: "SigninVC")
            signinVC?.modalPresentationStyle = .fullScreen
            present(signinVC!, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        activityIndication.stopAnimating()
        
    }
    
    @IBAction func unwindfFromSigninVC(unwindSegue: UIStoryboardSegue){
        print("Unwinded")
        if Auth.auth().currentUser != nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result:
        LoginManagerLoginResult?, error: Error?) {
        emailLogged = 0
        activityIndication.startAnimating()

        
        let r = GraphRequest(graphPath: "/me", parameters: ["fields":"id, email, name"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: HTTPMethod(rawValue: "GET"))

        var fbCompatible = false
        r.start(completionHandler: { (test, result, error) in
            if(error == nil)
            {
                let FBResult = result as! NSDictionary
                self.email = FBResult["email"] as! String
                self.name = FBResult["name"] as! String
                //self.id = FBResult["id"] as! String
                
                print("self.email after logging in Facebook in AuthVC \(self.email) and FBResult['name'] as! String \(FBResult["email"] as! String)")
                let randString = "FBUser" // .gitignore
                Authservice.instance.loginSocialUser(withEmail: self.email, andPassword: randString) { (success, error) in
                    if success {
                        print("Login Completed")
                        Dataservice.instance.save(forEmail: self.email) { (complete) in
                            if complete {
                                
                            }else {
                            
                            }
                        }
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        print("Login Error: \(error?.localizedDescription)")
                    }
                    
                    Authservice.instance.registerSocialUser(withEmail: self.email,withName: self.name, andPassword: randString) { (success, error) in
                        if success {
                            Authservice.instance.loginSocialUser(withEmail: self.email, andPassword: randString) { (success, error) in
                                print("Successfully Registered User \(self.email)")
                                Dataservice.instance.deleteAllDataFromCoreData { (done) in
                                    print(done)
                                }
                                Dataservice.instance.save(forEmail: self.email) { (complete) in
                                    print(complete)
                                }
                                let UploadVC = self.storyboard?.instantiateViewController(withIdentifier: "uploadVC")
                                UploadVC?.modalPresentationStyle = .fullScreen
                                self.present(UploadVC!, animated: true, completion: nil)
                                
                                
                                //self.dismiss(animated: true, completion: nil)
                            }
                        }else{
                            print("Registration error \(error?.localizedDescription)")
                        }
                    }
                }
                
            }// printing all emauil
        })
        
        
        activityIndication.stopAnimating()
    
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("FB Logged Out")
        Authservice.instance.signOut()
        Dataservice.instance.deleteAllDataFromCoreData { (complete) in
            if complete {
                print("Core Data Objects deleted")
            }else {
                print("Couldn't delete Core Data Objects")
            }
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        activityIndication.startAnimating()
        emailLogged = 0
        
        var compatble = false
        var googlePass = "googleUser" // .gitignore
        if let error = error {
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            print("The user has not signed in before or they have since signed out.")
          } else {
            print("\(error.localizedDescription)")
          }
          return
        }
        // Perform any operations on signed in user here.
        let userId = user.userID                  // For client-side use only!
        let idToken = user.authentication.idToken // Safe to send to the server
        let fullNamee = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let emaill = user.profile.email
        self.name = fullNamee!
        self.email = emaill!
        
        
        Authservice.instance.loginSocialUser(withEmail: self.email, andPassword: googlePass) { (success, error) in
            if success {
                print("Login Completed")
                Dataservice.instance.save(forEmail: self.email) { (complete) in
                    if complete {
                        
                    }else {
                    
                    }
                }
                self.dismiss(animated: true, completion: nil)
            }else{
                print("Login Error: \(error?.localizedDescription)")
            }
            
            Authservice.instance.registerSocialUser(withEmail: self.email,withName: self.name, andPassword: googlePass) { (success, error) in
                if success {
                    Authservice.instance.loginSocialUser(withEmail: self.email, andPassword: googlePass) { (success, error) in
                        print("Successfully Registered User")
                        Dataservice.instance.deleteAllDataFromCoreData { (done) in
                            print(done)
                        }
                        Dataservice.instance.save(forEmail: self.email) { (complete) in
                            print(complete)
                        }
                        let UploadVC = self.storyboard?.instantiateViewController(withIdentifier: "uploadVC")
                        UploadVC?.modalPresentationStyle = .fullScreen
                        self.present(UploadVC!, animated: true, completion: nil)
                        
                        
                        //self.dismiss(animated: true, completion: nil)
                    }
                }else{
                    print("Registration error \(error?.localizedDescription)")
                }
            }
            self.activityIndication.stopAnimating()
        }
        
        func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
                      withError error: Error!) {
//               Perform any operations when the user disconnects from app here.
//               ...
                Authservice.instance.signOut()
                Dataservice.instance.deleteAllDataFromCoreData { (complete) in
                    if complete {
                        print("Core Data Objects deleted")
                    }else {
                        print("Couldn't delete Core Data Objects")
                    }
                }
        }
        
        
    }

}

extension SFSafariViewController {
    override open var modalPresentationStyle: UIModalPresentationStyle {
        get { return .fullScreen}
        set {super.modalPresentationStyle = newValue}
    }
}


