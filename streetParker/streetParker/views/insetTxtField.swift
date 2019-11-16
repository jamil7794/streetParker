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
        let placeHolder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
        
        self.attributedPlaceholder = placeHolder
        super.awakeFromNib()
    }

}
