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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(LocationViewController.refreshData))
        
        self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: #selector(LocationViewController.pinMyLocation)))

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserLocationData.getInstance().locations.count == 0 {
            // retrieve locations from server
            parseAPI.getStudentsLocation(){ (result, error) in
                
                if let result = result , resultArray = result["results"] as? [AnyObject] {
                    for item in resultArray {
                        UserLocationData.appendLocation(UserLocationData.UserData(object: item))
                    }
                    performUIUpdatesOnMain({
                        self.onDataReload()
                    })
                }
                else
                {
                    let alertView = UIAlertController(title: "Loading parse data fail!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertView, animated: true, completion: nil)
                }
            }
        }
        else {
            self.onDataReload()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUIEnabled(enabled: Bool) {
        self.navigationItem.leftBarButtonItem?.enabled = enabled
        //self.navigationItem.rightBarButtonItem?.enabled = enabled
        for item in self.navigationItem.rightBarButtonItems! {
            item.enabled = enabled
        }
    }
    
    func onDataReload() {
        
    }

    
    func logOut() {
        setUIEnabled(false)
        udacityAPI.logout() { (result, error) in
            performUIUpdatesOnMain(){
                if error != NetworkError.NoError {
                    UserLocationData.reset()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                self.setUIEnabled(true)
            }
            
        }
    }
    
    func refreshData() {
        
    }

    func pinMyLocation() {
        
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
