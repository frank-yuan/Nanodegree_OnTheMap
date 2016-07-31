//
//  LocationEditViewController.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/31/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit
import MapKit

class LocationEditViewController: UIViewController {

    @IBOutlet weak var navBar : UINavigationBar!
    @IBOutlet weak var stackView : UIStackView!
    @IBOutlet weak var locationTextField : UITextField!
    @IBOutlet weak var linkTextField : UITextField!
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var button : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI(false)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onFound() {
        configureUI(true)
        
    }
    
    func configureUI(enableMapView:Bool) {
        stackView.hidden = enableMapView
        locationTextField.hidden = enableMapView
        linkTextField.hidden = !enableMapView
        mapView.hidden = !enableMapView
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
