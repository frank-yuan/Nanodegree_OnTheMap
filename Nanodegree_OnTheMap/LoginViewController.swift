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
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        subscribeToKeyboardNotifications()
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
        
        let header = ["Accept":"application/json", "Content-Type":"application/json" ]
        let httpBody = ["udacity":["username":email, "password":password]]
        let endPoint = HttpEndPoint(config: UdacityEndPointConfig())
        
        endPoint.post(httpBody, withPathExtension: "session", withHeaderParams: header) { (data, error) in
            HttpEndPoint.responseAdapterJSON(data, error: error, completeHandler: { (result, error) in
                guard error == NetworkError.NoError else {
                    displayError("Network Error!")
                    return
                }
                guard let account = result!["account"] else {
                    displayError("Cannot found account")
                    return
                }
                guard let registered = account!["registered"] as? Bool where registered else {
                    displayError("Cannot found account")
                    return
                }
                self.setUIEnabled(true)
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
                self.presentViewController(controller, animated: true, completion: nil)

            })
        }
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
    
    
    private func setUIEnabled(enabled: Bool) {
        textFieldPassword.enabled = enabled
        textFieldEmail.enabled = enabled
        buttonLogin.enabled = enabled
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
