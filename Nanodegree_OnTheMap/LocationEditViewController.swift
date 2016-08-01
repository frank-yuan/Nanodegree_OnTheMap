//
//  LocationEditViewController.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/31/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit
import MapKit

class LocationEditViewController: UIViewController , CLLocationManagerDelegate{

    @IBOutlet weak var navBar : UINavigationBar!
    @IBOutlet weak var stackView : UIStackView!
    @IBOutlet weak var locationTextField : UITextField!
    @IBOutlet weak var linkTextField : UITextField!
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var button : UIButton!
    
    
    let localSearch:MKLocalSearch? = nil
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textDelegate = TextFieldDelegate()
        locationTextField.delegate = textDelegate
        linkTextField.delegate = textDelegate
        
        configureUI(false)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSearch() {
    }
    
    @IBAction func onLocateMe() {
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .Denied{
            let alert = UIAlertController(title: "Location services", message: "Location services are not enabled. Please enable location services in settings.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            return
            
        } else if CLLocationManager.authorizationStatus() == .NotDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        //configureUI(true)
    }
    
    func configureUI(enableMapView:Bool) {
        stackView.hidden = enableMapView
        locationTextField.hidden = enableMapView
        linkTextField.hidden = !enableMapView
        mapView.hidden = !enableMapView
    }
    
    // MARK: Implement of UITextFieldDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            userLocation = locations.last!
            mapView.setCenterCoordinate(userLocation.coordinate, animated: true)
            configureUI(true)
        } else {
            onLocationNotFound()
        }
    }
    
    func onLocationNotFound() {
        
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
