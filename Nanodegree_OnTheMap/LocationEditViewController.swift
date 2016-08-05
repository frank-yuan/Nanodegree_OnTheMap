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
    private var locateDisabler : AutoSelectorCaller?
    
    
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
        
        let disableInteraction = AutoSelectorCaller(sender: self, startSelector: #selector(onBlock), releaseSelector: #selector(onBlockEnd))
        
        if locationTextField.text?.characters.count == 0 {
            showAlert("Type some thing to search")
            return
        }
        
        if let ls = localSearch where ls.searching {
            ls.cancel()
        }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = locationTextField.text
        
        localSearch = MKLocalSearch(request: request)
        localSearch!.startWithCompletionHandler(){ (response, error) in
            disableInteraction
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
        
        let disableInteraction = AutoSelectorCaller(sender: self, startSelector: #selector(onBlock), releaseSelector: #selector(onBlockEnd))
        
        if linkTextField.text?.characters.count == 0 {
            showAlert("Type your linkedin address")
            return
        }
        
        udacityAPI.getUserData(UserLocationData.getInstance().userId){ (result, error) in
            
            
            disableInteraction
            
            guard let result = result where error == NetworkError.NoError else {
                self.showAlert("Fail to submit.", buttonText: "OK")
                return
            }
            
            var data = [String:AnyObject]()
            if let user = result["user"]{
                data[Constant.ParseDataKey.uniqueKey] = AnyObjectHelper.parseData(user, name: "key", defaultValue: "");
                data[Constant.ParseDataKey.firstName] = AnyObjectHelper.parseData(user, name: "first_name", defaultValue: "");
                data[Constant.ParseDataKey.lastName] = AnyObjectHelper.parseData(user, name: "last_name", defaultValue: "");
                data[Constant.ParseDataKey.latitude] = self.userLocation.latitude
                data[Constant.ParseDataKey.longitude] = self.userLocation.longitude
                data[Constant.ParseDataKey.mapString] = self.locationTextField.text!
                data[Constant.ParseDataKey.mediaURL] = self.linkTextField.text!
            }
            parseAPI.postStudentLocation(data, objectId: self.objectId) { (result, error) in
                
                disableInteraction
                
                if (error != NetworkError.NoError)
                {
                    self.showAlert("Fail to submit your location", buttonText: "OK")
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func onLocateMe() {
        
        locateDisabler  = AutoSelectorCaller(sender: self, startSelector: #selector(onBlock), releaseSelector: #selector(onBlockEnd))
        
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .Denied{
            showAlert("Location services", buttonText: "OK", message: "Location services are not enabled. Please enable location services in settings.")
            return
            
        } else if CLLocationManager.authorizationStatus() == .NotDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.delegate = self
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: Delegate implementation of MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = UIColor.blueColor()
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
                    if nil == self.locateDisabler {
                        self.locateDisabler = nil
                        self.onLocationNotFound(error)
                    }
                    return
                }
                self.locateDisabler = nil
                
                self.configureMapView(location.coordinate)
                self.configureUI(true)
                self.locationTextField.text = placemarks?.last!.name
                
            }
        } else {
            if locateDisabler != nil {
                onLocationNotFound(nil)
                locateDisabler = nil
            }
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
        showAlert("Could not find places", buttonText: "OK", message: error == nil ? "" : error!.userInfo.description)
    }

    
    func onBlock() {
        view.userInteractionEnabled = false
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityView.center = self.view.center
        activityView.startAnimating()
        view.addSubview(activityView)
    }
    
    func onBlockEnd() {
        view.userInteractionEnabled = true
        if let activityView = view.subviews.last as? UIActivityIndicatorView {
            activityView.stopAnimating()
            activityView.removeFromSuperview()
        }
    }
}
