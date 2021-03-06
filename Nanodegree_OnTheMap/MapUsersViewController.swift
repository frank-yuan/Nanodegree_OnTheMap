//
//  MapUsersViewController.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/28/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit
import MapKit

class MapUsersViewController: UsersViewController,  MKMapViewDelegate{

    // MARK: IBOutlets
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var busyOverlay : UIImageView!
    
    // MARK: Variables
    var annotations = [MKPointAnnotation]()
    
    // MARK: UIViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true

        // Do any additional setup after loading the view.
    }
    
    // MARK: Superclass overrides
    override func setUIEnabled(enabled: Bool) {
        super.setUIEnabled(enabled)
        mapView.userInteractionEnabled = enabled
        busyOverlay.hidden = enabled
    }
    
    override func onDataReloaded() {
        
        super.onDataReloaded()
        
        self.mapView.removeAnnotations(annotations)
        
        annotations.removeAll()
        
        let locations = UserLocationData.getInstance().locations
        
        for user in locations {
            
            let lat = CLLocationDegrees(user.latitude)
            let long = CLLocationDegrees(user.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = user.firstName
            let last = user.lastName
            let mediaURL = user.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    // MARK: MKMapViewDelegate implements
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle!, url = NSURL(string: toOpen) where app.canOpenURL(url) {
                app.openURL(url)
            } else {
                showAlert("Invalid URL", buttonText: "OK", message: "The URL provided is invalid")
            }
        }
    }
    

}

