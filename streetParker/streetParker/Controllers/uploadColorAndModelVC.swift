//
//  uploadColorAndModelVC.swift
//  streetParker
//
//  Created by Jamil Jalal on 5/7/20.
//  Copyright © 2020 Jamil Jalal. All rights reserved.
//

import UIKit
import Firebase

class uploadColorAndModelVC: UIViewController {
    
    @IBOutlet weak var doneBtn: customizedButton!
    
    @IBOutlet weak var nameTxt: insetTxtField!
    
    @IBOutlet weak var licensePlateTxt: insetTxtField!
    
    @IBOutlet weak var carColorTxt: insetTxtField!
    var emailValue = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        doneBtn.isHidden = false
        doneBtn.bindToKeyboard()
        Dataservice.instance.getNameForEmail(forEmail: (Auth.auth().currentUser?.email)!) { (name) in
            self.nameTxt.text = name
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func doneBtnPressed(_ sender: Any) {
        
        var currentUserEmail = (Auth.auth().currentUser?.email)!
        
        
 
        if Auth.auth().currentUser != nil {
            
            Dataservice.instance.uploadCarInfo(forEmail: (Auth.auth().currentUser?.email)!, forName: nameTxt.text!, forLicPlate: licensePlateTxt.text!, forCarColor: carColorTxt.text!) { (success) in
                print(success)
                let pvc = self.presentingViewController
                self.dismiss(animated: true) {
                    pvc?.dismiss(animated: true, completion: nil)
                }
                
            }
            
        
            print("doneBtnPressed in uploadColorAndModelVC")
        }else{
            print("User is nil in uploadColorAndModelVC")
        }
        //Authservice.instance.signOut()
    }
    
}
