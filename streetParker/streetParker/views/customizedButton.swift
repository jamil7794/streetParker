//
//  customizedButton.swift
//  streetParker
//
//  Created by Jamil Jalal on 11/13/19.
//  Copyright © 2019 Jamil Jalal. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class customizedButton: UIButton {

  
    override func awakeFromNib() {
        layer.cornerRadius = 10
        layer.backgroundColor = #colorLiteral(red: 0.2642766497, green: 0.2642766497, blue: 0.2642766497, alpha: 0.5288152825)
    }
    
}
