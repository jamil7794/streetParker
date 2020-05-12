//
//  SigninVC.swift
//  streetParker
//
//  Created by Jamil Jalal on 11/14/19.
//  Copyright © 2019 Jamil Jalal. All rights reserved.
//

import UIKit
import Firebase

class SigninVC: UIViewController {

    
    @IBOutlet weak var signinBtn: customizedButton!
    
    @IBOutlet weak var emailField: insetTxtField!
    @IBOutlet weak var passwordField: insetTxtField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signinBtn.isHidden = false
        signinBtn.bindToKeyboard()
        emailField.delegate = self
        passwordField.delegate = self

        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil{
            print("Auth.auth().currentUser in SigninVC")
            let pvc = self.presentedViewController
            self.dismiss(animated: true) {
                pvc?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    
    @IBAction func closePressed(_ sender: Any) {
        
    }
    
    @IBAction func signInButtonWasPressed(_ sender: Any) {
        if emailField.text != nil && passwordField.text != nil {
            Authservice.instance.loginUser(withEmail: emailField.text!, andPassword: passwordField.text!) { (success, error) in
                
                if success {
                    print("Logged In successfully")
                    Dataservice.instance.deleteAllDataFromCoreData { (complete) in
                        if complete {
                            
                        }else{
                            
                        }
                    }
                    //self.presentingViewController?.dismiss(animated: true, completion: nil)
                    let pvc = self.presentingViewController
                    Dataservice.instance.save(forEmail: self.emailField.text!) { (success) in
                        if success {
                            print("SIgninVC: Saved")
                        }else{
                            print("SignedinVC: Not Saved")
                        }
                    }
                    self.dismiss(animated: true) {
                        pvc?.dismiss(animated: true, completion: nil)
                    }
                    
                }else{
                    print(error?.localizedDescription as! String)
                }
                
                Authservice.instance.registerUser(withEmail: self.emailField.text!, andPassword: self.passwordField.text!, userCreationComplete: { (success, registrationUser) in
                    
                    if success {
                        Authservice.instance.loginUser(withEmail: self.emailField.text!, andPassword: self.passwordField.text!, loginComplete: { (success, nil) in
                            
                            print("Successfully registered user")
                            //self.dismiss(animated: true, completion: nil)
                            //self.performSegue(withIdentifier: "SigninToAuth", sender: self)
                            if #available(iOS 13.0, *) {
                                let UploadVC = self.storyboard?.instantiateViewController(withIdentifier: "uploadVC")
                                UploadVC?.modalPresentationStyle = .fullScreen
                                self.present(UploadVC!, animated: true, completion: nil)
                            } else {
                                // Fallback on earlier versions
                            }
                        })
                    }else{
                        print(registrationUser?.localizedDescription as! String)
                    }
                    
                })
            }
            
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is uploadColorAndModelVC {
            let vc = segue.destination as? uploadColorAndModelVC
            vc?.emailValue = 1
        }
    }
}

extension SigninVC: UITextFieldDelegate {
    
}
