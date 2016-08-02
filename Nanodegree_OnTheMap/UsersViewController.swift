//
//  UsersViewController.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/28/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController {
    
    let locationEditViewSegue = "showLocationEditView"
    var objectId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "On The Map"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(UsersViewController.logOut))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(UsersViewController.reloadData))
        
        self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: #selector(UsersViewController.pinMyLocation)))

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserLocationData.getInstance().locations.count == 0 {
            reloadData()
        }
        else {
            self.onDataReloaded()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == locationEditViewSegue) {
            if let vc = segue.destinationViewController as? LocationEditViewController {
                vc.objectId = objectId
            }
        }
        
    }
    
    func setUIEnabled(enabled: Bool) {
        self.navigationItem.leftBarButtonItem?.enabled = enabled
        for item in self.navigationItem.rightBarButtonItems! {
            item.enabled = enabled
        }
        
        tabBarController?.view.userInteractionEnabled = enabled

        
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
    
    func onDataReloaded() {
        
    }

    
    func logOut() {
        setUIEnabled(false)
        udacityAPI.logout() { (result, error) in
            performUIUpdatesOnMain(){
                if error != NetworkError.NoError {
                    self.showAlert("Logout with error!", message: "", completionHandler: nil)
                }
                UserLocationData.reset()
                self.dismissViewControllerAnimated(true, completion: nil)
                self.setUIEnabled(true)
            }
        }
    }
    
    func reloadData() {
        setUIEnabled(false)
        // retrieve locations from server
        parseAPI.getStudentsLocation(){ (result, error) in
            
            if let result = result , resultArray = result["results"] as? [AnyObject] {
                
                UserLocationData.clearLocation()
                
                for item in resultArray {
                    UserLocationData.appendLocation(UserLocationData.UserData(object: item))
                }
                
                performUIUpdatesOnMain({
                    self.onDataReloaded()
                    self.setUIEnabled(true)
                })
            }
            else
            {
                self.setUIEnabled(true)
                self.showAlert("Loading parse data fail!", message: "", completionHandler: nil)
            }
        }
    }

    func pinMyLocation() {
        setUIEnabled(false)
        parseAPI.getStudentLocation(UserLocationData.getInstance().userId) { (result, error) in
            if let results = result!["results"] as? [AnyObject] where results.count > 0 {
                let alertView = UIAlertController(title: "Already set your location", message: "You have set your location before, do you want to override?", preferredStyle: UIAlertControllerStyle.Alert)
                alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                alertView.addAction(UIAlertAction(title: "Overrite", style: UIAlertActionStyle.Default) {(action) -> Void in
                    let objectId = AnyObjectHelper.parseData(results[0], name: "objectId", defaultValue: "")
                    self.pushLocationEditView(objectId)
                    })
                self.presentViewController(alertView, animated: true, completion: nil)

            } else {
                self.pushLocationEditView("")
            }
            self.setUIEnabled(true)
        }
    }
    
    func pushLocationEditView(objectId:String) {
        self.objectId = objectId
        performSegueWithIdentifier(locationEditViewSegue, sender: self)
    }
    
    func showAlert(title: String, message: String, completionHandler: (()->Void)? ) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertView, animated: true, completion: completionHandler)
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
