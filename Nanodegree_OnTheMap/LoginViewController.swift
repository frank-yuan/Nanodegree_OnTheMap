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

    // MARK: IBOutles
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    
    // MARK: Variables and constants
    var viewOriginY:CGFloat = 0
    let textFieldDelegate = TextFieldDelegate()
    
    // MARK: UIViewController overrides
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

    override func viewWillDisappear(animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: IBActions
    @IBAction func onLogin() {
        let disableInteraction = AutoSelectorCaller(sender: self, startSelector: #selector(blockInteraction), releaseSelector: #selector(unblockInteraction))
        
        
        guard let email = textFieldEmail.text where email.characters.count > 0 else {
            showAlert("Email cannot be empty")
            return
        }
        
        guard let password = textFieldPassword.text where password.characters.count > 0 else {
            showAlert("Password cannot be empty")
            return
        }
        
        udacityAPI.authenticate(email, password:password) { (result, error) in
            
            disableInteraction
            
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
                self.showAlert(errorMsg)
                return
            }
            
            guard let account = result!["account"] else {
                self.showAlert("Cannot found account in result")
                return
            }
            
            guard let registered = account!["registered"] as? Bool where registered else {
                self.showAlert("Unknown error")
                return
            }
            
            guard let userId = account!["key"] as? String else {
                self.showAlert("Cannot find user Id")
                return
            }
            
            UserLocationData.setUserId(userId)
            
            
            self.onLoggedIn()
        }
    }
    
    @IBAction func onSignup() {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://www.udacity.com/account/auth#!/signup")!)
    }
    
    // MARK: Private methods
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
    
    func blockInteraction() {
        buttonLogin.enabled = false
        view.userInteractionEnabled = false
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityView.center = view.center
        activityView.startAnimating()
        view.addSubview(activityView)
    }
    
    func unblockInteraction() {
        buttonLogin.enabled = true
        view.userInteractionEnabled = true
        if let activityView = view.subviews.last as? UIActivityIndicatorView {
            activityView.stopAnimating()
            activityView.removeFromSuperview()
        }
    }
}
