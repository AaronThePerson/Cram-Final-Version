//
//  DiscoverViewController.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 4/4/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DiscoverViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var mapListController: UISegmentedControl!
    
    let mapView = MapViewController()
    let listView = ListViewController()
    
    var userLocation: CLLocationCoordinate2D!
    let manager = CLLocationManager()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        prepareLocation()
    }
    
    private func prepareLocation(){
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    private func getUserLocation(){
    }
    
    private func prepareUI(){
        let mapViewContainer = mapView.view
        let listViewContainer = listView.view
        container.addSubview(listViewContainer!)
        container.addSubview(mapViewContainer!)
    }

    @IBAction func switchView(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            container.bringSubview(toFront: mapView.view)
        case 1:
            container.bringSubview(toFront: listView.view)
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        userLocation = CLLocationCoordinate2DMake(locations[0].coordinate.latitude, locations[0].coordinate.longitude)
        
        let region: MKCoordinateRegion = MKCoordinateRegionMake(userLocation, span)
        
        mapView.map.setRegion(region, animated: false)
        
        mapView.map.showsUserLocation = true
    }
    
}
