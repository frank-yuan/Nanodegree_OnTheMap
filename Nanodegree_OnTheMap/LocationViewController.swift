//
//  LocationViewController.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/28/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "On The Map"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(LocationViewController.logOut))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(LocationViewController.reloadData))
        
        self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: #selector(LocationViewController.pinMyLocation)))

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
    
    func setUIEnabled(enabled: Bool) {
        self.navigationItem.leftBarButtonItem?.enabled = enabled
        for item in self.navigationItem.rightBarButtonItems! {
            item.enabled = enabled
        }
        self.tabBarController?.tabBar.userInteractionEnabled = enabled
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
