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
    
    
    

    @IBOutlet weak var googleView: UIView!
    
    @IBOutlet weak var FBView: UIView!
    
    @IBOutlet weak var viewss: UIView!
    var email =  String()
    var id: String?
    var name = String()
    var data: userContents?
    var flag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        
        if let token = AccessToken.current,
            !token.isExpired {
            self.dismiss(animated: true, completion: nil)
        }
    
       if Auth.auth().currentUser != nil {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser != nil {
            self.dismiss(animated: true, completion: nil)
        }
        
//        if let presenter = presentingViewController as? FindVC {
//            presenter.name = self.name
//        }
        
        if let token = AccessToken.current,!token.isExpired {
            if Auth.auth().currentUser != nil {
                print("Facbook user is already logged in")
            }else{
                print("Facbook user is not logged in")
            }
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {

    }

    @IBAction func signInWithInstagram(_ sender: Any) {
        
    }
    
    @IBAction func signInWithEmail(_ sender: Any) {
        if #available(iOS 13.0, *) {
            let signinVC = storyboard?.instantiateViewController(withIdentifier: "SigninVC")
            signinVC?.modalPresentationStyle = .fullScreen
            present(signinVC!, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
        
    }
    
    @IBAction func unwindfFromSigninVC(unwindSegue: UIStoryboardSegue){
        print("Unwinded")
        if Auth.auth().currentUser != nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func FBAction(){
        //NotificationCenter.default.post(name: Notification.Name("FBPressed"), object: nil)
        //self.dismiss(animated: true, completion: nil)
    }
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result:
        LoginManagerLoginResult?, error: Error?) {
        print("Login Complete")
        let r = GraphRequest(graphPath: "/me", parameters: ["fields":"id, email, name"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: HTTPMethod(rawValue: "GET"))

        var fbCompatible = false
        r.start(completionHandler: { (test, result, error) in
            if(error == nil)
            {
                let FBResult = result as! NSDictionary
                self.email = FBResult["email"] as! String
                self.name = FBResult["name"] as! String
                self.id = FBResult["id"] as! String
                
                
                let randString = "FBUser" // .gitignore
                
                Dataservice.instance.printAllEmails(forEmail: self.email) { (emails) in
                    for em in emails {
                        if em == self.email {
                            
                            Authservice.instance.loginSocialUser(withEmail: self.email, andPassword: randString) { (success, error) in
                                if success {
                                    print("AuthVC: Facebook User Logged in as " + self.name)
                                    
                                    Dataservice.instance.deleteAllDataFromCoreData { (complete) in
                                        if complete {
                                            print("Core Data Objects deleted")
                                        }else {
                                            print("Couldn't delete Core Data Objects")
                                        }
                                    }
                                    
                                    
                                    fbCompatible = true
                                    self.save { (complete) in
                                        if complete {
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                    
                                }else{
                                    print("Facebook User Logging ERROR: " + error!.localizedDescription)
                                }
                            }
                            
                        }else{
                            print(em + "   " + self.email + " not compatible")
                        }
                        
                        //
                    }
                    
                    //for em in email
                    if fbCompatible == false {
                        Authservice.instance.registerSocialUser(withEmail: self.email, withName: self.name, andPassword: randString) { (success, error) in
                            
                            if success {
                                print("Facebook User Created: " + self.email)
                                
                                
                                
                                Authservice.instance.loginSocialUser(withEmail: self.email, andPassword: randString) { (success, error) in
                                        if success {
                                            print("AuthVC: Facebook User Logged in as " + self.name)
                           
                                            
                                            
                                            
                                                              
                                            self.dismiss(animated: true, completion: nil)
                                        }else{
                                            print("Facebook User Logging ERROR: " + error!.localizedDescription)
                                                                }
                                                            }
                            }else{
                                print("Facebook User Creation ERROR: " + error!.localizedDescription)
                            }
                        }
                    }
                }
            }
        })
        
        
    
    
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("FB Logged Out")
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
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
        
        
        Dataservice.instance.printAllEmails(forEmail: self.email) { (emails) in
                            for em in emails {
                                if em == self.email {
                                    
                                    Authservice.instance.loginSocialUser(withEmail: self.email, andPassword: googlePass) { (success, error) in
                                        if success {
                                            print("AuthVC: Google User Logged in as " + self.name)
        
                                            compatble = true
                                            
                                            Dataservice.instance.deleteAllDataFromCoreData { (complete) in
                                                if complete {
                                                    print("Core Data Objects deleted")
                                                }else {
                                                    print("Couldn't delete Core Data Objects")
                                                }
                                            }
                                            
                                            
                                            self.save { (complete) in
                                                if complete {
                                                    self.dismiss(animated: true, completion: nil)
                                                }
                                            }
                                            
                                            
                                        }else{
                                            print("Google User Logging ERROR: " + error!.localizedDescription)
                                        }
                                    }
                                    
                                }else{
                                    print(em + "   " + self.email + " not compatible")
                                    
                                }
                            }
            if (compatble == false){
                print("Compatible: \(compatble)")
                print("email: \(self.email)")
                print("Name: \(self.name)")
                print("googlePass: \(googlePass)")
                
                Authservice.instance.registerSocialUser(withEmail: self.email, withName: self.name, andPassword: googlePass) { (success, error) in
                    
                    if success {
                        print("Google User Created: " + self.email)
                        
                        
                        
                        Authservice.instance.loginSocialUser(withEmail: self.email, andPassword: googlePass) { (success, error) in
                            if success {
                                print("AuthVC: Google User Logged in as " + self.name)
                                
                                
                                
                                
                                
                                self.dismiss(animated: true, completion: nil)
                            }else{
                                print("Google User Logging ERROR: " + error!.localizedDescription)
                            }
                        }
                    }else{
                        print("Google User Creation ERROR: " + error!.localizedDescription)
                    }
                }
            }
        }
        
    }
    
    func save(completion: (_ finished: Bool) -> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let user = UserAndCar(context: managedContext)
        user.userEmail = self.email
        user.userName = self.name
        
        do{
           try managedContext.save()
            print("User Info successfully saved")
            completion(true)
        } catch {
            print("Could not save data: \(error.localizedDescription)")
            completion(false)
        }
        
    }

    
}

extension SFSafariViewController {
    override open var modalPresentationStyle: UIModalPresentationStyle {
        get { return .fullScreen}
        set {super.modalPresentationStyle = newValue}
    }
}



