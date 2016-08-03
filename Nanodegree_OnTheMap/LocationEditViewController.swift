//
//  LocationEditViewController.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/31/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit
import MapKit

class LocationEditViewController: UIViewController , CLLocationManagerDelegate, MKMapViewDelegate{

    // MARK: IBOutlet
    @IBOutlet weak var stackView : UIStackView!
    @IBOutlet weak var locationTextField : UITextField!
    @IBOutlet weak var linkTextField : UITextField!
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var searchButton : UIButton!
    @IBOutlet weak var submitButton : UIButton!
    
    // MARK: Constant
    private let textDelegate = TextFieldDelegate()
    private let locationManager = CLLocationManager()
    private let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.112872, longitudeDelta: 0.109863)
    
    // MARK: Fields
    var objectId = ""
    private var localSearch:MKLocalSearch? = nil
    private var userLocation = CLLocationCoordinate2D()
    
    
    // MARK: UIViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextField.delegate = textDelegate
        linkTextField.delegate = textDelegate
        
        configureUI(false)
        // Tap anywhere to end editing
        let tapper = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper);
    }
    
    // MARK: IBActions
    @IBAction func onCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSearch() {
        
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
    
    @IBAction func onSubmit() {
        
        if linkTextField.text?.characters.count == 0 {
            showAlert("Type your linkedin address", message: "", buttonText: "OK")
            return
        }
        
        udacityAPI.getUserData(UserLocationData.getInstance().userId){ (result, error) in
            guard let result = result where error == NetworkError.NoError else {
                self.showAlert("Fail to submit.", message: "", buttonText: "OK")
                return
            }
            
            var data = [String:AnyObject]()
            if let user = result["user"]{
                data["uniqueKey"] = AnyObjectHelper.parseData(user, name: "key", defaultValue: "");
                data["firstName"] = AnyObjectHelper.parseData(user, name: "first_name", defaultValue: "");
                data["lastName"] = AnyObjectHelper.parseData(user, name: "last_name", defaultValue: "");
                data["latitude"] = self.userLocation.latitude
                data["longitude"] = self.userLocation.longitude
                data["mapString"] = self.locationTextField.text!
                data["mediaURL"] = self.linkTextField.text!
            }
            parseAPI.postStudentLocation(data, objectId: self.objectId) { (result, error) in
                if (error != NetworkError.NoError)
                {
                    self.showAlert("Fail to submit your location", message: "", buttonText: "OK")
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
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
    
    // MARK: Delegate implementation of MKMapViewDelegate
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
    
    // MARK: Implement of CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            let location = locations.last!
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
                if (error != nil || placemarks?.count == 0) {
                    self.onLocationNotFound(error)
                    return
                }
                
                self.configureMapView(location.coordinate)
                self.configureUI(true)
                self.locationTextField.text = placemarks?.last!.name
                
            }
        } else {
            onLocationNotFound(nil)
        }
    }
    
    
    // MARK: Private functions
    
    private func configureUI(enableMapView:Bool) {
        stackView.hidden = enableMapView
        locationTextField.hidden = enableMapView
        linkTextField.hidden = !enableMapView
        mapView.hidden = !enableMapView
        searchButton.hidden = enableMapView
        submitButton.hidden = !enableMapView
    }
    
    private func configureMapView(coordinate: CLLocationCoordinate2D) {
        userLocation = coordinate
        mapView.setCenterCoordinate(coordinate, animated: true)
        mapView.setRegion(MKCoordinateRegion(center: coordinate, span: coordinateSpan), animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    @objc private func handleSingleTap(sender:UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    private func onLocationNotFound(error:NSError?) {
        showAlert("Could not find places", message: error == nil ? "" : error!.userInfo.description, buttonText: "OK")
    }
    
    private func showAlert(title: String, message: String, buttonText: String) {
        
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: buttonText, style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
    }
}
