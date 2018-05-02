//
//  CreatePostViewController.swift
//  Cram Final Version
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

class CreatePostViewController: UIViewController {

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
    
    @IBAction func createPost(_ sender: Any) {
        
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
        print(postKey!)

        locationRef?.setLocation(location, forKey: postKey!)
        
        dismiss(animated: true, completion: nil)
    }
    
}
