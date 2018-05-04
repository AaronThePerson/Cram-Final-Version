//
//  PostDetailViewController.swift
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
//  Created by Aaron Speakman on 4/24/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase

class PostDetailViewController: UIViewController {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postDescriptionView: UITextView!
    @IBOutlet weak var viewProfileButton: UIButton!
    
    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
    
    var detailPost = Post()
    var otherUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {  //load user of post
        getUserFromFirebase(uid: detailPost.uid!) { (someUser) in
            self.otherUser = someUser
        }
    }

    func prepareUI(){
        username.text = detailPost.username
        viewProfileButton.layer.cornerRadius = 5
        titleLabel.text = detailPost.title
        postDescriptionView.text = detailPost.postDescription
    }
    
    func getUserFromFirebase(uid: String, completion: @escaping (User?)-> Void){  //retireve user information from Firebase
        let usersRef = ref.child("users")
        let someUser = User()
        usersRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
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
                default: break
                }
            }
            completion(someUser)
        }, withCancel: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {  
        if segue.identifier == "viewProfilePost"{
            let vc = segue.destination as! ViewProfileViewController
            vc.isFromPost = true
            vc.otherUser = otherUser
        }
    }
    
    @IBAction func viewProfile(_ sender: Any) {
        performSegue(withIdentifier: "viewProfilePost", sender: Any?.self)
    }
    @IBAction func backToPosts(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
