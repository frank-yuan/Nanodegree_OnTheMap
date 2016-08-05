//
//  UsersViewController.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/28/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController {
    
    
    // MARK: Fields
    let locationEditViewSegue = "showLocationEditView"
    var objectId = ""
    var activityIndicatorView : UIActivityIndicatorView?

    // MARK: UIViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "On The Map"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(UsersViewController.logOut))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(UsersViewController.reloadData))
        
        self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: #selector(UsersViewController.pinMyLocation)))

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
    
    // MARK: Virtual Methods
    func setUIEnabled(enabled: Bool) {
        
        self.navigationItem.leftBarButtonItem?.enabled = enabled
        
        for item in self.navigationItem.rightBarButtonItems! {
            item.enabled = enabled
        }
        
        tabBarController?.view.userInteractionEnabled = enabled
    }
    
    func onDataReloaded() {
    }

    
    // MARK: Private Methods
    final func logOut() {
        
        let disableInteraction = AutoSelectorCaller(sender: self, startSelector: #selector(blockInteraction), releaseSelector: #selector(unblockInteraction))
        
        udacityAPI.logout() { (result, error) in
            
            performUIUpdatesOnMain(){
                
                disableInteraction
                
                if error != NetworkError.NoError {
                    self.showAlert("Logout with error!")
                }
                UserLocationData.reset()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    final func reloadData() {
        
        let disableInteraction = AutoSelectorCaller(sender: self, startSelector: #selector(blockInteraction), releaseSelector: #selector(unblockInteraction))
        
        // retrieve locations from server
        parseAPI.getStudentsLocation(){ (result, error) in
            
            disableInteraction
            
            if let result = result , resultArray = result["results"] as? [AnyObject] {
                
                UserLocationData.clearLocation()
                
                for item in resultArray {
                    UserLocationData.appendLocation(UserLocationData.UserData(object: item))
                }
                
                performUIUpdatesOnMain({
                    self.onDataReloaded()
                })
            }
            else
            {
                self.showAlert("Loading parse data fail!")
            }
        }
    }

    final func pinMyLocation() {
        
        let disableInteraction = AutoSelectorCaller(sender: self, startSelector: #selector(blockInteraction), releaseSelector: #selector(unblockInteraction))
        
        parseAPI.getStudentLocation(UserLocationData.getInstance().userId) { (result, error) in
            
            disableInteraction
            
            if let results = result!["results"] as? [AnyObject] where results.count > 0 {
                let alertView = UIAlertController(title: "Already set your location", message: "You have set your location before, do you want to overwrite?", preferredStyle: UIAlertControllerStyle.Alert)
                alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                alertView.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default) {(action) -> Void in
                    self.objectId = AnyObjectHelper.parseData(results[0], name: "objectId", defaultValue: "")
                    self.performSegueWithIdentifier(self.locationEditViewSegue, sender: self)
                    })
                self.presentViewController(alertView, animated: true, completion: nil)

            } else {
                self.objectId = ""
                self.performSegueWithIdentifier(self.locationEditViewSegue, sender: self)
            }
        }
    }
    
    final func blockInteraction() {
        setUIEnabled(false)
        view.userInteractionEnabled = false
        activityIndicatorView  = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicatorView!.center = self.view.center
        activityIndicatorView!.startAnimating()
        view.addSubview(activityIndicatorView!)
    }
    
    final func unblockInteraction() {
        setUIEnabled(true)
        view.userInteractionEnabled = true
        if nil != activityIndicatorView {
            activityIndicatorView!.stopAnimating()
            activityIndicatorView!.removeFromSuperview()
        }
        activityIndicatorView = nil
    }

}
