//
//  ProfileChangesTableViewController.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 4/30/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase

class ProfileChangesTableViewController: UITableViewController {

    @IBOutlet weak var navTitle: UINavigationItem!
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
            
        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "fromTableToProfile", sender: self)
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
    
    func getPosts(completion: ()->Void){
        //let friendRef = ref.child("users").child((Auth.auth().currentUser?.uid)!).child("post")
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
