//
//  LocationEditViewController.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/31/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit

class LocationEditViewController: UIViewController {

    @IBOutlet weak var navBar : UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(LocationEditViewController.onCancel))

        // Do any additional setup after loading the view.
    }
    
    func onCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onFound() {
        dismissViewControllerAnimated(false) { () -> Void in
            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LocationMapViewController") {
                self.presentViewController(vc, animated: false, completion: nil)
            }
        }
        
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
