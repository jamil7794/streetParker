//
//  ViewController.swift
//  streetParker
//
//  Created by Jamil Jalal on 11/13/19.
//  Copyright © 2019 Jamil Jalal. All rights reserved.
//

import UIKit

class AuthVC: UIViewController {
    
    
    
    @IBOutlet weak var viewss: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.viewss.layer.cornerRadius = 15.0
    }

    @IBAction func signInWithFacebook(_ sender: Any) {
        
    }
    
    @IBAction func signInWithInstagram(_ sender: Any) {
        
    }
    
    @IBAction func signInWithEmail(_ sender: Any) {
        let signinVC = storyboard?.instantiateViewController(withIdentifier: "SigninVC")
        present(signinVC!, animated: true, completion: nil)
    }
    
}

