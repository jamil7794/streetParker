//
//  insetTxtField.swift
//  streetParker
//
//  Created by Jamil Jalal on 11/15/19.
//  Copyright © 2019 Jamil Jalal. All rights reserved.
//

import UIKit

class insetTxtField: UITextField {

    private var padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    //textRectOffset = how far we want to shift the rectangle
    // padding = what should it look like on its rectangle itself?
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    // palceHolder
    override func awakeFromNib() {
        let placeHolder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)])
        
        self.attributedPlaceholder = placeHolder
        super.awakeFromNib()
    }

}
