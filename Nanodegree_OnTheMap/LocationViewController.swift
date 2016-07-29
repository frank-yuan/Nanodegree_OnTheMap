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
            if let url = HttpServiceHelper.buildURL(ParseServiceConfig(), withPathExtension: "StudentLocation", queryItems: ["limit":100]) {
                let request = HttpRequest(url: url)
                request.addHeader([Constant.ParseApi.applicationIdKey: Constant.ParseApi.applicationIdValue,
                    Constant.ParseApi.apiKeyKey: Constant.ParseApi.apiKeyValue])
                
                HttpService.service(request) { (data, error) in
                    HttpServiceHelper.parseJSONResponse(data, error: error){ (result, networkError) in
                        if let result = result , resultArray = result["results"] as? [AnyObject] {
                            print (resultArray[0])
                        }
                        else
                        {
                            let alertView = UIAlertController(title: "Loading parse data fail!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                            alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alertView, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func logOut() {
        UserLocationData.reset()
        dismissViewControllerAnimated(true, completion: nil)
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
