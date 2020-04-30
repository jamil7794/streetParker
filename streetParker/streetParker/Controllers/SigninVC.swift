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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("x")
    }
    
    
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signInButtonWasPressed(_ sender: Any) {
        if emailField.text != nil && passwordField.text != nil {
            Authservice.instance.loginUser(withEmail: emailField.text!, andPassword: passwordField.text!) { (success, error) in
                
                if success {
                    print("Logged In successfully")
                    self.dismiss(animated: true, completion: nil)
          
                }else{
                    print(error?.localizedDescription as! String)
                }
                
                Authservice.instance.registerUser(withEmail: self.emailField.text!, andPassword: self.passwordField.text!, userCreationComplete: { (success, registrationUser) in
                    
                    if success {
                        Authservice.instance.loginUser(withEmail: self.emailField.text!, andPassword: self.passwordField.text!, loginComplete: { (success, nil) in
                            self.dismiss(animated: true, completion: nil)
                            
                            print("Successfully registered user")
                        })
                    }else{
                        print(registrationUser?.localizedDescription as! String)
                    }
                    
                })
            }
            
            
        }
    }
    
}

extension SigninVC: UITextFieldDelegate {
    
}
