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

class AuthVC: UIViewController, SFSafariViewControllerDelegate, LoginButtonDelegate {
  
    
    @IBOutlet weak var FBView: UIView!
    
    @IBOutlet weak var viewss: UIView!
    var email: String?
    var id: String?
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewss.layer.cornerRadius = 15.0
        
        let FBButton = FBLoginButton()
        FBButton.delegate = self
        FBButton.center = FBView.center
        FBView.addSubview(FBButton)
        
    
        FBButton.addTarget(self, action: #selector(FBAction), for: .touchUpInside)
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear AuthVC")
        
        if Auth.auth().currentUser != nil {
            self.dismiss(animated: true, completion: nil)
        }
        
//        if let token = AccessToken.current,
//            !token.isExpired {
//            self.dismiss(animated: true, completion: nil)
//        }
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

        r.start(completionHandler: { (test, result, error) in
            if(error == nil)
            {
                let FBResult = result as! NSDictionary
                self.email = FBResult["email"] as! String
                self.name = FBResult["name"] as! String
                self.id = FBResult["id"] as! String
                
                
                let randNum = Int.random(in: 1111111 ... 9999999)
                let randString = "FBUser"
                
                Dataservice.instance.printAllEmails(forEmail: self.email!) { (emails) in
                    for em in emails {
                        if em == self.email! {
                            
                            Authservice.instance.loginFBUser(withEmail: self.email!, andPassword: randString) { (success, error) in
                                if success {
                                    print("Facebook User Logged in")
                                }else{
                                    print("Facebook User Logging ERROR: " + error!.localizedDescription)
                                }
                            }
                            
                        }else{
                            print(em + "   " + self.email! + " not compatible")
                            Authservice.instance.registerFBUser(withEmail: self.email!, withName: self.name!, andPassword: randString) { (success, error) in
                                
                                if success {
                                    print("Facebook User Created: " + self.email!)
                                }else{
                                    print("Facebook User Creation ERROR: " + error!.localizedDescription)
                                }
                            }
                        }
                    }
                }
                
//                Authservice.instance.loginUser(withEmail: self.email!, andPassword: randString) { (success, error) in
//                    if success {
//                        print("Logged in FIrebase")
//                    }else{
//                        print("Firebase Error: " + error!.localizedDescription as! String)
//                        Authservice.instance.registerFBUser(withEmail: self.email!, ) { (success, error) in
//                            if success {
//                                print("Facebook user created")
//                            }else{
//                                print("Facebook user not created: " + error!.localizedDescription as! String)
//                            }
//                        }
//                    }
//                }
                
            }
        })
        self.dismiss(animated: true, completion: nil)
    
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("FB Logged Out")
    }
    
}
extension SFSafariViewController {
    override open var modalPresentationStyle: UIModalPresentationStyle {
        get { return .fullScreen}
        set {super.modalPresentationStyle = newValue}
    }
}



