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

class AuthVC: UIViewController {
    
    @IBOutlet weak var FBView: UIView!
    
    @IBOutlet weak var viewss: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewss.layer.cornerRadius = 15.0
        let FBButton = FBLoginButton()
        FBButton.center = FBView.center
        FBView.addSubview(FBButton)
        // Do any additional setup after loading the view.
    
        FBButton.addTarget(self, action: #selector(FBAction), for: .touchUpInside)
        
        if let token = AccessToken.current,
            !token.isExpired {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        if let token = AccessToken.current, !token.isExpired {
//            // User is logged in, do work such as go to next view controller.
//            self.dismiss(animated: true, completion: nil)
//        }
        
        if Auth.auth().currentUser != nil {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear AuthVC")
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if #available(iOS 13.0, *) {
            print("x")
            if segue.destination.modalPresentationStyle == .formSheet {
                segue.destination.modalPresentationStyle = .fullScreen
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
}

