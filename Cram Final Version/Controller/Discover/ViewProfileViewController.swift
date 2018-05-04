//
//  ViewProfileViewController.swift
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
//  Created by Aaron Speakman on 4/17/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase

class ViewProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileDescriptionField: UITextView!
    @IBOutlet weak var userCoursesTable: UITableView!
    @IBOutlet weak var universityLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    
    var isFriended: Bool = false  //used to toggle friend button
    var isFromPost: Bool = false //used to determine if previous view was a detailed post
    var otherUser: User?
    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")  //Reference for Firebase
    let usersRef = Database.database().reference().child("users")
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    func prepareUI(){  //general UI function to setup UI
        profilePicImageView.layer.cornerRadius = 10.0
        profilePicImageView.layer.masksToBounds = true
        profilePicImageView.layer.borderWidth = 4.0
        profilePicImageView.layer.borderColor = (UIColor.white).cgColor
        
        chatButton.layer.cornerRadius = 5
        addFriendButton.layer.cornerRadius = 5
        profileDescriptionField.layer.cornerRadius = 5
        
        usernameLabel.text = otherUser?.username
        universityLabel.text = otherUser?.university
        majorLabel.text = otherUser?.major
        profileDescriptionField.text = otherUser?.profileDescription
        if isFromPost != true{
            checkIfFriended()
            userCoursesTable.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChat"{
            let nav = segue.destination as! UINavigationController
            let vc = nav.viewControllers[0] as! ChatLogTableViewController
            let name = "Chat With " + (otherUser?.username)! + " & " + (currentUser?.username)!
            let members = [Friend(uid: (otherUser?.uid)!, username: (otherUser?.username)!), Friend(uid: (currentUser?.uid)!, username: (currentUser?.username)!)]
            let groupId = ref.child("groups").childByAutoId().key
            let newGroup = Group(groupName: name, groupID: groupId, members: members)
            addGroupToFirebase(newGroup: newGroup) {
                vc.selectedGroup = newGroup
                vc.performSegue(withIdentifier: "goToChatLog", sender: self)
            }
        }
    }
    
    func addGroupToFirebase(newGroup: Group, completion: ()->Void){
        let num: Int = (newGroup.members?.count)!
        var membersDict: [String: Any] = [:]
        for i in 0..<num{
            membersDict[(newGroup.members?[i].uid)!] = newGroup.members?[i].username as AnyObject
            ref.child("users").child((newGroup.members?[i].uid)!).child("groups").child(newGroup.groupID).child("groupName").setValue(newGroup.groupName)
        }
        ref.child("groups").child(newGroup.groupID).child("groupName").setValue(newGroup.groupName)
        ref.child("groups").child(newGroup.groupID).child("members").updateChildValues(membersDict)
        completion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if currentUser?.uid == nil{
            getProfile(givenUID: (Auth.auth().currentUser?.uid)!) { (someUser) in
                currentUser = someUser
                if otherUser?.uid == Auth.auth().currentUser?.uid{  // To handle is the user is the same
                    chatButton.isHidden = true
                    addFriendButton.isHidden = true
                    prepareUI()
                }
            }
        }
        else if otherUser?.uid == Auth.auth().currentUser?.uid{  // To handle is the user is the same
            chatButton.isHidden = true
            addFriendButton.isHidden = true
            prepareUI()
        }
    }
    
    @IBAction func BackToDiscover(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func getProfile(givenUID: String, completion: (User)->Void){
        if givenUID != ""{
            let someUser = User()
            usersRef.child(givenUID).observeSingleEvent(of: DataEventType.value) { (snapshot) in
                someUser.uid = snapshot.key
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
                        someUser.username = data.value as? String
                    case "profilePicURL": break
                    case "courses":
                        var courses: [Course] = []
                        let courseSnap = data.children
                        while let courseKey = courseSnap.nextObject() as? DataSnapshot{
                            let someCourse = Course()
                            if let courseDictionary = courseKey.value as? [String: AnyObject]{
                                someCourse.courseID = courseKey.key
                                someCourse.courseName = courseDictionary["courseName"] as? String
                                someCourse.courseCode = courseDictionary["courseCode"] as? String
                                someCourse.prof = courseDictionary["prof"] as? String
                            }
                            courses.append(someCourse)
                        }
                        someUser.courses = courses
                    case "friends":
                        var friends : [Friend] = []
                        let friendSnap = data.children
                        var someFriend: Friend?
                        while let friendKey = friendSnap.nextObject() as? DataSnapshot{
                            if let friendDictionary = friendKey.value as? [String: AnyObject]{
                                let id = friendKey.key
                                let username = friendDictionary["username"] as? String
                                someFriend = Friend(uid: id, username: username!)
                            }
                            friends.append(someFriend!)
                        }
                        someUser.friends = friends
                    default: break
                    }
                }
            }
            completion(someUser)
        }
    }
    
    func checkIfFriended(){
        let num: Int = (currentUser?.friends.count)!
        for i in 0..<num{
            if currentUser?.friends[i].uid == otherUser?.uid{
                addFriendButton.setTitle("Friended", for: UIControlState.normal)
            }
        }
    }
    
    @IBAction func addFriend(_ sender: Any) {
        var friended = false
        let num: Int = (currentUser?.friends.count)!
        var userFoundAt: Int? = nil
        for i in 0..<num{
            if currentUser?.friends[i].uid == otherUser?.uid{
                friended = true
                userFoundAt = i
                break
            }
        }
        if friended == true{
            usersRef.child((currentUser?.uid)!).child("friends").child((otherUser?.uid)!).removeValue()
            currentUser?.friends.remove(at: userFoundAt!)
            addFriendButton.setTitle("Add Friend", for: UIControlState.normal)
        }
        else{
            usersRef.child((currentUser?.uid!)!).child("friends").child((otherUser?.uid)!).child("username").setValue(otherUser?.username)
            currentUser?.friends.append(Friend(uid: (otherUser?.uid)!, username: (otherUser?.username)!))
            addFriendButton.setTitle("Friended", for: UIControlState.normal)
        }
    }
    
    @IBAction func chatWith(_ sender: Any) {
        performSegue(withIdentifier: "goToChat", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My Courses"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (otherUser?.courses.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCourseCell")
        
        cell?.textLabel?.text = otherUser?.courses[indexPath.row].courseName
        cell?.detailTextLabel?.text = otherUser?.courses[indexPath.row].courseCode
        
        return cell!
    }
    
    
}
