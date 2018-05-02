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
    
    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
    let usersRef = Database.database().reference().child("users")
    
    let userMapView = MapViewController()
    let listView = ListViewController()
    var userTable = UITableView()
    
    var dataFilter = Filter(distance: 5, university: false, major: false, selectedCourses: [])
    
    var currentUser: User?
    var userLocation = CLLocation()
    var userCoordinates: CLLocationCoordinate2D!
    let manager = CLLocationManager()
    
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
        prepareCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getOtherUsers{
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        manager.stopUpdatingLocation()
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
        getOtherUsers {
        }
    }
    
    @IBAction func openfilter(_ sender: Any) {
        performSegue(withIdentifier: "goToFilter", sender: Any?.self)
    }
    
    @IBAction func refreshUsers(_ sender: Any) {
        listView.resetToNil()
        addUserLocation()
        getOtherUsers {}
    }
    
    private func prepareDatabase(){
        locationRef = GeoFire(firebaseRef: (ref.child("locations")))
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
        getUserFromFirebase(uid: (Auth.auth().currentUser?.uid)!, location: userLocation) { (returnedUser) in
            self.currentUser = returnedUser!
            self.userMapView.setCurrentUser(someUser: self.currentUser!)
            self.listView.setCurrentUser(someUser: self.currentUser!)
        }
    }
    
    private func addUserLocation(){
        userLocation = CLLocation(latitude: userCoordinates.latitude, longitude: userCoordinates.longitude)
        currentUser?.location = userLocation
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
        self.listView.resetUsersArray()
        circleQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            if key != Auth.auth().currentUser?.uid{
                nearbyUsers.append(otherUser(key: key, otherLocation: location))
            }
        })
        
        circleQuery?.observeReady{
            for i in 0..<nearbyUsers.count{
                var filterCheck: Bool = true
                
                self.getUserFromFirebase(uid: nearbyUsers[i].key, location: nearbyUsers[i].otherLocation,completion: { (someUser) in
                    
                    if self.dataFilter.university == true {
                        if someUser?.university != self.currentUser?.university{
                            filterCheck = false
                        }
                    }
                    
                    if self.dataFilter.major == true{
                        if someUser?.major != self.currentUser?.major{
                            filterCheck = false
                        }
                    }
                    
                    if self.dataFilter.selectedCourses?.count != 0{
                        let num: Int = (self.currentUser?.courses.count)!
                        let someNum: Int = (someUser?.courses.count)!
                        var matchFound: Bool = false
                        for i in 0..<someNum{
                            for j in 0..<num{
                                if self.currentUser?.courses[j].courseCode == someUser?.courses[i].courseCode || self.currentUser?.courses[j].courseName == someUser?.courses[i].courseName{
                                    matchFound = true
                                }
                            }
                        }
                        if matchFound != true{
                            filterCheck = false
                        }
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
        let usersRef = ref.child("users")
        let someUser = User()
        usersRef.child(uid).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            someUser.uid = snapshot.key
            someUser.location = location
            let snapChildren = snapshot.children
            while let data = snapChildren.nextObject() as? DataSnapshot{
                switch data.key{
                case "major":
                    someUser.major = data.value as? String
                case "university":
                    someUser.university = data.value as? String
                case "username":
                    someUser.username = data.value as? String
                case "profileDescription":
                    someUser.profileDescription = data.value as? String
                case "profilePicURL": break
                case "courses":
                    let courseSnap = data.children
                    while let courseKey = courseSnap.nextObject() as? DataSnapshot{
                        let someCourse = Course()
                        if let courseDictionary = courseKey.value as? [String: AnyObject]{
                            someCourse.courseID = courseKey.key
                            someCourse.courseName = courseDictionary["courseName"] as? String
                            someCourse.courseCode = courseDictionary["courseCode"] as? String
                            someCourse.prof = courseDictionary["prof"] as? String
                        }
                        someUser.courses.append(someCourse)
                    }
                case "friends":
                    let friendSnap = data.children
                    while let friendKey = friendSnap.nextObject() as? DataSnapshot{
                        if let friendDictionary = friendKey.value as? [String: AnyObject]{
                            let id = friendKey.key
                            let username = friendDictionary["username"] as? String
                            someUser.friends.append(Friend(uid: id, username: username!))
                        }
                    }
                    print(someUser.friends.count)
                default: break
                }
            }
            completion(someUser)
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
