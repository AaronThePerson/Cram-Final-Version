//
//  MapViewController.swift
//  Cram Final Version
//
//
//Copyright © 2018 Aaron Speakman.
//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//  Created by Aaron Speakman on 4/4/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var map: MKMapView!
    
    var currentLocation = CLLocation()
    var currentUser: User?
    var userProfiles: [String: User] = [:]
    var uid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {  //creates an annotation on the map
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.reuseIdentifier == "student"{
            uid = (view.annotation as! StudentPoint).uid
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {  //displays more details when tapper
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "viewProfile") as! ViewProfileViewController
        vc.otherUser = userProfiles[uid!]!
        vc.currentUser = currentUser
        self.show(vc, sender: self)
    }
    
    func setCurrentUserLocation(userLocation: CLLocation){
        currentLocation = userLocation
    }
    
    func calculateDistance(otherlocation: CLLocation) -> Double{
        let distance = otherlocation.distance(from: currentLocation)
        return (distance/1609.34)
    }
    
    func addUserAnnotation(someUser: User){
        userProfiles[someUser.uid!] = someUser
        let distance = String(format: "%.3f", calculateDistance(otherlocation: someUser.location!)) + " miles"
        let annotation = StudentPoint(username: someUser.username!, distance: distance, uid: someUser.uid!, location: someUser.location!)
        map.addAnnotation(annotation)
    }
    
    func setCurrentUser(someUser: User){
        currentUser = someUser
    }
    
    func resetAnnotations(){ //clear old data from map
        map.removeAnnotations(map.annotations)
    }
    

}
