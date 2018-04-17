//
//  MapViewController.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 4/4/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var map: MKMapView!
    
    var currentLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKMarkerAnnotationView()
        guard let annotation = annotation as? StudentPoint else{
            return nil
        }
        
        
        let identifier = "student"
        
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView{
            annotationView = dequedView
        } else{
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
            annotationView.calloutOffset = CGPoint(x: -5, y: 5)
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView.isEnabled = true
        }
        
        annotationView.markerTintColor = UIColor.blue
        annotationView.glyphImage = UIImage(named: "student icon")
        annotationView.glyphTintColor = UIColor.white
        annotationView.clusteringIdentifier = identifier
        
        return annotationView
    }
    
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        mapView.selectAnnotation(annotaion, animated: true)
//    }
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//
//    }
    
    func setCurrentUserLocation(userLocation: CLLocation){
        currentLocation = userLocation
    }
    
    func calculateDistance(otherlocation: CLLocation) -> Double{
        let distance = otherlocation.distance(from: currentLocation)
        return (distance/1609.34)
    }
    
    func addUserAnnotation(someUser: User){
        let distance = String(format: "%.3f", calculateDistance(otherlocation: someUser.location!)) + " miles"
        let annotation = StudentPoint(username: someUser.username!, distance: distance, uid: someUser.uid!, location: someUser.location!)
        map.addAnnotation(annotation)
    }
    
    func resetAnnotations(){ //clear old data from map
        map.removeAnnotations(map.annotations)
    }
    

}
