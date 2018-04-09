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
import Firebase
import GeoFire

class DiscoverViewController: UIViewController, CLLocationManagerDelegate, SendFilter {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var mapListController: UISegmentedControl!
    
    let mapView = MapViewController()
    let listView = ListViewController()
    
    var dataFilter = Filter(distance: 5, university: false, major: false)
    
    var userLocation = CLLocation()
    var userCoordinates: CLLocationCoordinate2D!
    let manager = CLLocationManager()
    
    var ref: DatabaseReference?
    var locationRef: GeoFire?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareDatabase()
        prepareUI()
        prepareLocation()
    }
    
    func setFilter(filter: Filter) {
        self.dataFilter = filter
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFilter"{
            let vc = segue.destination as! FilterViewController
            vc.delegate = self
            vc.dataFilter = dataFilter
        }
    }
    
    @IBAction func openfilter(_ sender: Any) {
        performSegue(withIdentifier: "goToFilter", sender: Any?.self)
    }
    
    private func prepareDatabase(){
        ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
        locationRef = GeoFire(firebaseRef: (ref?.child("locations"))!)
    }
    
    private func prepareLocation(){
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = CLLocationDistance(exactly: 15.0)!
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    private func prepareUI(){
        let mapViewContainer = mapView.view
        let listViewContainer = listView.view
        container.addSubview(listViewContainer!)
        container.addSubview(mapViewContainer!)
    }
    
    private func addUserLocation(){
        userLocation = CLLocation(latitude: userCoordinates.latitude, longitude: userCoordinates.longitude)
        locationRef?.setLocation(userLocation, forKey: (Auth.auth().currentUser?.uid)!)
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
        
        userCoordinates = CLLocationCoordinate2DMake(locations[0].coordinate.latitude, locations[0].coordinate.longitude)
        
        let region: MKCoordinateRegion = MKCoordinateRegionMake(userCoordinates, span)
        
        mapView.map.setRegion(region, animated: false)
        
        mapView.map.showsUserLocation = true
        
        addUserLocation()
    }
    
}
