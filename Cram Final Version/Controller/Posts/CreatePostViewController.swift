//
//  CreatePostViewController.swift
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
import GeoFire

extension Date { //Used to timestamp posts
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

class CreatePostViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var createWindow: UIView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var postButton: UIButton!
    
    var currentUser: User?
    
    var ref: DatabaseReference?
    var locationRef: GeoFire?
    var location =  CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareDatabase()
        prepareUI()
    }
    @IBAction func cancelBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    private func prepareDatabase(){
        ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
        locationRef = GeoFire(firebaseRef: (ref?.child("post-locations"))!)
    }
    
    func prepareUI(){
        createWindow.layer.cornerRadius = 5
        postButton.layer.cornerRadius = 5
        descriptionField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func createPost(_ sender: Any) {  //submit a post to Firebase
        
        let postRef = ref?.child("posts")
        let postKey = ref?.childByAutoId().key
        
        let title = titleField.text
        let description = descriptionField.text
        
        let values: [String: AnyObject] = ["title": title as AnyObject, "description": description as AnyObject, "uid": currentUser?.uid as AnyObject, "username": currentUser?.username as AnyObject, "timestamp": Date().toMillis() as AnyObject]
        
        postRef?.child(postKey!).updateChildValues(values, withCompletionBlock: { (initialWriteError, ref) in
            if initialWriteError != nil{
                print(initialWriteError!)
                return
            }
        })
        ref?.child("users").child((Auth.auth().currentUser?.uid)!).child("posts").child(postKey!).child("title").setValue(title)

        locationRef?.setLocation(location, forKey: postKey!)
        
        dismiss(animated: true, completion: nil)
    }
    
}
