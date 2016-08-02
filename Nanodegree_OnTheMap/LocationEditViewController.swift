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
    
    
    var localSearch:MKLocalSearch? = nil
    let textDelegate = TextFieldDelegate()
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = textDelegate
        linkTextField.delegate = textDelegate
        
        configureUI(false)
        // Do any additional setup after loading the view.
        let tapper = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper);
    }
    
    @IBAction func onCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSearch() {
        
        locationTextField.resignFirstResponder()
        if locationTextField.text?.characters.count == 0 {
            showAlert("Type some thing to search", message: "", buttonText: "OK")
            return
        }
        
        if let ls = localSearch where ls.searching {
            ls.cancel()
        }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = locationTextField.text
        
        localSearch = MKLocalSearch(request: request)
        localSearch!.startWithCompletionHandler(){ (response, error) in
            if let error = error {
                self.onLocationNotFound(error)
            } else {
                let mapItem = response?.mapItems.last
                self.configureMapView((mapItem?.placemark.coordinate)!)
                self.configureUI(true)
            }
        }
    }
    
    @IBAction func onLocateMe() {
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .Denied{
            showAlert("Location services", message: "Location services are not enabled. Please enable location services in settings.", buttonText: "OK")
            return
            
        } else if CLLocationManager.authorizationStatus() == .NotDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.delegate = self
        locationManager.stopUpdatingLocation()
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
            configureMapView(userLocation.coordinate)
            configureUI(true)
        } else {
            onLocationNotFound(nil)
        }
    }
    
    func onLocationNotFound(error:NSError?) {
        showAlert("Could not find places", message: error == nil ? "" : error!.userInfo.description, buttonText: "OK")
    }
    
    func configureMapView(coordinate: CLLocationCoordinate2D) {
        
        mapView.setCenterCoordinate(coordinate, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func handleSingleTap(sender:UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    func showAlert(title: String, message: String, buttonText: String) {
        
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: buttonText, style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = UIColor.redColor()
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }


}
