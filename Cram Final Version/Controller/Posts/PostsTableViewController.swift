//
//  PostsTableViewController.swift
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
import Firebase
import GeoFire

class PostsTableViewController: UITableViewController, CLLocationManagerDelegate {

    var ref: DatabaseReference?
    var locationRef: GeoFire?
    var posts: [Post] = []
    
    var manager = CLLocationManager()
    var userLocation = CLLocation()
    
    var currentUser = User()
    var selectedPost = Post()
    
    let refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        prepareDatabase()
        prepareLocation()
        getCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPosts {  //get posts on load
            self.tableView.reloadData()
        }
    }
    
    private func prepareDatabase(){
        ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
        locationRef = GeoFire(firebaseRef: (ref?.child("post-locations"))!)
    }
    
    private func prepareLocation(){
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = CLLocationDistance(exactly: 15.0)!
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func getCurrentUser(){
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: DataEventType.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.currentUser.university = (dictionary["university"] as? String)
                self.currentUser.major = (dictionary["major"] as? String)
                self.currentUser.profileDescription = (dictionary["profileDescription"] as? String)
                self.currentUser.username = (dictionary["username"] as? String)
                self.currentUser.uid = snapshot.key
            }
        }
    }

    func prepareUI(){
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(PostsTableViewController.reloadData(_:)), for: .valueChanged)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
    }
    
    @objc func reloadData(_ sender: Any){
        getPosts {
            self.tableView.reloadData()
            //self.posts = self.posts.sorted(by: {$0.timeStamp! < $1.timeStamp!})
            self.refresh.endRefreshing()
        }
    }
    
    func getPosts(completion: @escaping ()->Void){  //gets posts within 15 miles
        
        var keys: [String] = []
        posts = [] //clear posts
        
        let miles = 15 * Double(1.60934)
        let circleQuery = self.locationRef?.query(at: self.userLocation, withRadius: miles)
        circleQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            keys.append(key)
        })
        
        circleQuery?.observeReady {
            for i in 0..<keys.count{
                self.getPostfromFirebase(key: keys[i], completion: { (somePost) in
                    self.posts.append(somePost!)
                    self.posts = self.posts.sorted(by: {$0.timeStamp! > $1.timeStamp!})
                    self.tableView.reloadData()
                })
            }
            completion()
        }
        
    }
    
    func getPostfromFirebase(key: String, completion: @escaping (Post?)-> Void){  //given a key retrieves post
        self.ref?.child("posts").child(key).observe(DataEventType.value, with: { (snapshot) in
            let somePost = Post()
            if let dictionary = snapshot.value as? [String: AnyObject]{
                somePost.postID = snapshot.key
                somePost.title = dictionary["title"] as? String
                somePost.uid = dictionary["uid"] as? String
                somePost.username = dictionary["username"] as? String
                somePost.postDescription = dictionary["description"] as? String
                somePost.timeStamp = Int64((dictionary["timestamp"] as! Int64))
            }
            completion(somePost)
        }, withCancel: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createPost"{
            let vc = segue.destination as! CreatePostViewController
            vc.location = userLocation
            vc.currentUser = currentUser
        }
        else if segue.identifier == "postDetails"{
            let vc = segue.destination as! PostDetailViewController
            vc.detailPost = selectedPost
        }
    }
    
    @IBAction func createPost(_ sender: Any) {  //builds a post model
        performSegue(withIdentifier: "createPost", sender: Any?.self)
    }
    
    func convertTimestamp(timestamp: Int64)->String{
        let dateNum = timestamp/1000
        let date = Date(timeIntervalSince1970: TimeInterval(dateNum))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        return dateFormatter.string(from: date)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //presents the post in a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostsTableViewCell
        
        cell.titleLabel.text = posts[indexPath.row].title
        cell.descriptionLabel.text = posts[indexPath.row].postDescription
        cell.timeLabel.text = convertTimestamp(timestamp: posts[indexPath.row].timeStamp!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPost = posts[indexPath.row]
        performSegue(withIdentifier: "postDetails", sender: Any?.self)
    }
}
