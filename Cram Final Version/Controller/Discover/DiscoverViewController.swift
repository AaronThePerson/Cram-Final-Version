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

class DiscoverViewController: UIViewController, CLLocationManagerDelegate, SendFilter{
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var mapListController: UISegmentedControl!
    
    let userMapView = MapViewController()
    let listView = ListViewController()
    var userTable = UITableView()
    
    var dataFilter = Filter(distance: 5, university: false, major: false, selectedCourses: [])
    
    let currentUser = User()
    var userLocation = CLLocation()
    var userCoordinates: CLLocationCoordinate2D!
    let manager = CLLocationManager()
    
    var ref: DatabaseReference?
    var locationRef: GeoFire?
    var mappableUsers = [User]()
    
    var viewProfileUID: String = ""
    
    let kiloToMile = Double(1.60934)
    var miles: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareDatabase()
        prepareUI()
        prepareLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getOtherUsers{
            for i in 0..<self.mappableUsers.count{
                self.mappableUsers[i].writeData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFilter"{
            let vc = segue.destination as! FilterViewController
            vc.delegate = self
            vc.dataFilter = dataFilter
        }
    }
    
    func setFilter(filter: Filter) {
        self.dataFilter = filter
    }
    
    @IBAction func openfilter(_ sender: Any) {
        performSegue(withIdentifier: "goToFilter", sender: Any?.self)
    }
    
    @IBAction func refreshUsers(_ sender: Any) {
        listView.resetToNil()
        addUserLocation()
        getOtherUsers {
            print(self.mappableUsers.count)
            for i in 0..<self.mappableUsers.count{
                self.mappableUsers[i].writeData()
            }
        }
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
        let mapViewContainer = userMapView.view
        let listViewContainer = listView.view
        container.addSubview(listViewContainer!)
        container.addSubview(mapViewContainer!)
        userTable = listView.userList
    }
    
    private func prepareCurrentUser(){
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: DataEventType.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.currentUser.university = (dictionary["university"] as? String)
                self.currentUser.major = (dictionary["major"] as? String)
                self.currentUser.profileDescription = (dictionary["profileDescription"] as? String)
                self.currentUser.uid = snapshot.key
            }
        }
    }
    
    private func addUserLocation(){
        userLocation = CLLocation(latitude: userCoordinates.latitude, longitude: userCoordinates.longitude)
        locationRef?.setLocation(userLocation, forKey: (Auth.auth().currentUser?.uid)!)
        listView.setCurrentUserLocation(userLocation: userLocation)
        userMapView.setCurrentUserLocation(userLocation: userLocation)
    }
    
    func getOtherUsers(completion: ()->Void){
        struct otherUser{
            var key: String
            var otherLocation: CLLocation
            
            init(key: String, otherLocation: CLLocation) {
                self.key = key
                self.otherLocation = otherLocation
            }
        }
        var nearbyUsers: [otherUser] = []
        
        self.miles = Double(self.dataFilter.distance!) * self.kiloToMile
        let circleQuery = self.locationRef?.query(at: self.userLocation, withRadius: self.miles!)
        self.userMapView.resetAnnotations()
        self.mappableUsers = [] //clear old user data
        circleQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            if key != Auth.auth().currentUser?.uid{
                nearbyUsers.append(otherUser(key: key, otherLocation: location))
            }
        })
        
        circleQuery?.observeReady{
            print("Locations Loaded")
            for i in 0..<nearbyUsers.count{
                let filterCheck: Bool = true
                
                self.getUserFromFirebase(uid: nearbyUsers[i].key, location: nearbyUsers[i].otherLocation,completion: { (someUser) in
                    //someUser?.writeData()
                    if self.dataFilter.university == true {
                        if someUser?.university != self.currentUser.university{
                            print("university match")
                        }
                    }
                    
                    if self.dataFilter.major == true{
                        if someUser?.major != self.currentUser.major{
                            print("major match")
                        }
                    }
                    
                    if self.dataFilter.selectedCourses?.count != 0{
                        print("courses selected")
                    }
                    if filterCheck == true{
                        self.userMapView.addUserAnnotation(someUser: someUser!)
                        self.listView.addUser(addedUser: someUser!)
                    }
                })
                
            }
    }
    completion()
}

    func getUserFromFirebase(uid: String, location: CLLocation, completion: @escaping (User?)-> Void){
        let usersRef = Database.database().reference().child("users")
        let someUser = User()
        usersRef.child(uid).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                someUser.uid = snapshot.key
                someUser.location = location
                someUser.username = (dictionary["username"] as? String)
                someUser.university = (dictionary["university"] as? String)
                someUser.major = (dictionary["major"] as? String)
                
//                let courseSnap = snapshot.childSnapshot(forPath: "courses")
//                let someCourse = Course()
//                if let courseDictionary = courseSnap.value as? [String: AnyObject]{
//                    someCourse.courseID = courseSnap.key
//                    someCourse.courseName = courseDictionary["courseName"] as? String
//                    someCourse.courseCode = courseDictionary["courseCode"] as? String
//                    someCourse.prof = courseDictionary["prof"] as? String
//                }
              
        
                
//                self.getUserCoursesFromFirebase(uid: uid, completion: { (returnedCourses) in
//                    someUser.courses = returnedCourses
//                })
            }
            completion(someUser)
        }, withCancel: nil)
    }
    
    func getUserCourseFromFirebase(uid: String, completion: @escaping (Course?)-> Void){
        let coursesRef = Database.database().reference().child("users").child(uid).child("courses")
        let someCourse = Course()
        coursesRef.observeSingleEvent(of: .value, with: { (courseSnap) in
            if let courseDictionary = courseSnap.value as? [String: AnyObject]{
                someCourse.courseID = courseSnap.key
                someCourse.courseName = courseDictionary["courseName"] as? String
                someCourse.courseCode = courseDictionary["courseCode"] as? String
                someCourse.prof = courseDictionary["prof"] as? String
            }
            completion(someCourse)
        }, withCancel: nil)
    }

    @IBAction func switchView(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            container.bringSubview(toFront: userMapView.view)
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
        userMapView.map.setRegion(region, animated: false)
        userMapView.map.showsUserLocation = true
        
        addUserLocation()
    }
    
}
