//
//  TextFieldDelegate.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/27/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
}
