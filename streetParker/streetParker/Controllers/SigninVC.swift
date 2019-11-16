//
//  SigninVC.swift
//  streetParker
//
//  Created by Jamil Jalal on 11/14/19.
//  Copyright © 2019 Jamil Jalal. All rights reserved.
//

import UIKit

class SigninVC: UIViewController {

    
    @IBOutlet weak var signinBtn: customizedButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signinBtn.isHidden = false
        signinBtn.bindToKeyboard()


        // Do any additional setup after loading the view.
    }
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
