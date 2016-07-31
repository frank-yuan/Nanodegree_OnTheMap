//
//  LoginViewController.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/27/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//
import Foundation
import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var keepMeLoggedIn: UISwitch!
    
    var viewOriginY:CGFloat = 0
    let textFieldDelegate = TextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewOriginY = view.frame.origin.y
        textFieldEmail.delegate = textFieldDelegate
        textFieldPassword.delegate = textFieldDelegate

        let tapper = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper);
    }
    
    override func viewWillAppear(animated: Bool) {
        textFieldPassword.text = nil
        subscribeToKeyboardNotifications()
    }
    override func viewDidAppear(animated: Bool) {
        if UserLocationData.load() {
            onLoggedIn()
        }
    }
    override func viewWillDisappear(animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: IBAction
    @IBAction func onLogin() {
        
        func displayError(errorTitle: String, errorMessage: String? = nil) {
            self.setUIEnabled(true)
            let alertView = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        }
        
        setUIEnabled(false)
        
        guard let email = textFieldEmail.text where email.characters.count > 0 else {
            displayError("Email cannot be empty")
            return
        }
        
        guard let password = textFieldPassword.text where password.characters.count > 0 else {
            displayError("Password cannot be empty")
            return
        }
        
        udacityAPI.authenticate(email, password:password) { (result, error) in
            guard error == NetworkError.NoError else {
                var errorMsg = ""
                switch error {
                case NetworkError.ParseJSONError:
                    errorMsg = "Result cannot be parsed!"
                case NetworkError.ResponseWrongStatus:
                    errorMsg = "Account not found or invalid credentials."
                default:
                    errorMsg = "Network error."
                }
                displayError(errorMsg)
                return
            }
            
            guard let account = result!["account"] else {
                displayError("Cannot found account in result")
                return
            }
            
            guard let registered = account!["registered"] as? Bool where registered else {
                displayError("Unknown error")
                return
            }
            
            guard let userId = account!["key"] as? String else {
                displayError("Cannot find user Id")
                return
            }
            
            UserLocationData.setUserId(userId)
            
            if self.keepMeLoggedIn.on {
                UserLocationData.save()
            }
            self.setUIEnabled(true)
            
            self.onLoggedIn()
        }
    }
    
    @IBAction func onSignup() {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://www.udacity.com/account/auth#!/signup")!)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let textField = textFieldEmail.editing ? textFieldEmail : textFieldPassword
        view.frame.origin.y = viewOriginY - getKeyboardHeight(notification) + (view.frame.maxY - textField.frame.maxY) / 2
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = viewOriginY
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func handleSingleTap(sender:UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    func onLoggedIn() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    private func setUIEnabled(enabled: Bool) {
        textFieldPassword.enabled = enabled
        textFieldEmail.enabled = enabled
        buttonLogin.enabled = enabled
        keepMeLoggedIn.enabled = enabled
        
        if (!enabled) {
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            activityView.center = view.center
            view.addSubview(activityView)
            activityView.startAnimating()
        } else {
            if let subview = view.subviews.last as? UIActivityIndicatorView {
                subview.stopAnimating()
                subview.removeFromSuperview()
            }
        }
        
    }
}
