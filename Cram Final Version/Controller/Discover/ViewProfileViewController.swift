//
//  ViewProfileViewController.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 4/17/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase

class ViewProfileViewController: UIViewController {

    @IBOutlet weak var uidLabel: UILabel!
    
    var isFriended: Bool = false
    var otherUser: User?
    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
    let usersRef = Database.database().reference().child("users")
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        uidLabel.text = otherUser?.uid
    }

    override func viewWillAppear(_ animated: Bool) {

        if currentUser?.uid == nil{
            getProfile(givenUID: (Auth.auth().currentUser?.uid)!) { (someUser) in
                currentUser = someUser
            }
        }
//        getProfile(givenUID: uid!) { (someUser) in
//            otherUser = someUser
//        }
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
        
    }
    
    @IBAction func addFriend(_ sender: Any) {
        var friended = false
        let num: Int = (currentUser?.friends.count)!
        var userFoundAt: Int? = nil
        for i in 0..<num{
            if currentUser?.friends[i].uid == otherUser?.uid{
                friended = true
                userFoundAt = i
            }
        }
        if friended == true{
            usersRef.child((currentUser?.uid)!).child("friends").child((otherUser?.uid)!).removeValue()
            currentUser?.friends.remove(at: userFoundAt!)
            print("unfriend")
        }
        else{
            usersRef.child((currentUser?.uid!)!).child("friends").child((otherUser?.uid)!).child("username").setValue(otherUser?.username)
            currentUser?.friends.append(Friend(uid: (otherUser?.uid)!, username: (otherUser?.username)!))
            print("friended")
        }
    }
    
    @IBAction func chatWith(_ sender: Any) {
        
    }
}
