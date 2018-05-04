//
//  ProfileChangesListViewController.swift
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
//  Created by Aaron Speakman on 5/3/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase

class ProfileChangesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var changeType: String?
    var friends: [Friend] = []
    var posts: [Post] = []
    
    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if changeType == "Manage Friends"{
            getFriends {
                
            }
        }
        else if changeType == "Manage Posts"{
            getPosts {
                
            }
        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func getFriends(completion: @escaping ()->Void){
        let friendRef = ref.child("users").child((Auth.auth().currentUser?.uid)!).child("friends")
        friendRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let snapFriends = snapshot.children
            while let friendKey = snapFriends.nextObject() as? DataSnapshot{
                if let friendDictionary = friendKey.value as? [String: AnyObject]{
                    let id = friendKey.key
                    let friendsUsername = friendDictionary["username"] as? String
                    self.friends.append(Friend(uid: id, username: friendsUsername!))
                }
            }
            completion()
        }, withCancel: nil)
    }
    
    func getPosts(completion: ()->Void){  //post manager to get posts from firebase (yet to be completly finished)
        var postKey: [String] = []
        let userPostRef = ref.child("user").child((Auth.auth().currentUser?.uid)!).child("posts")
        userPostRef.observe(.value) { (snapshot) in
            let postChildren = snapshot.children
            while let data = postChildren.nextObject() as? DataSnapshot{
                let key = snapshot.key
            }
        }
    }
    
    func getPostfromFirebase(key: String, completion: @escaping (Post?)-> Void){  //retieve posts and builds post data model
        self.ref.child("posts").child(key).observe(DataEventType.value, with: { (snapshot) in
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
    
    //These functions set up the table view accordingly
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if changeType == "Manage Friends"{
            return "Friends"
        }
        else if changeType == "Manage Posts"{
            return "Posts"
        }
        else{
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if changeType == "Manage Friends"{
            return friends.count
        }
        else if changeType == "Manage Posts"{
            return posts.count
        }
        else{
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileChangesCell", for: indexPath)
        if changeType == "Manage Friends"{
            cell.textLabel?.text = friends[indexPath.row].username
        }
        else if changeType == "Manage Posts"{
            cell.textLabel?.text = posts[indexPath.row].title
            cell.detailTextLabel?.text = posts[indexPath.row].postDescription
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if changeType == "Manage Friends"{
                ref.child("users").child((Auth.auth().currentUser?.uid)!).child("friends").child(friends[indexPath.row].uid).removeValue()
                friends.remove(at: indexPath.row)
            }
            else if changeType == "Manage Posts"{
                ref.child("users").child((Auth.auth().currentUser?.uid)!).child("posts").child("post").child(posts[indexPath.row].postID!).removeValue()
                ref.child("posts").child(posts[indexPath.row].postID!).removeValue()
                ref.child("post-locations").child(posts[indexPath.row].postID!).removeValue()
                posts.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    



}
