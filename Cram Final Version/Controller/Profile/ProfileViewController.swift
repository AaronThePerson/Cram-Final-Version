//
//  ProfileViewController.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 3/27/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userDescriptionField: UITextView!
    
    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveUser()
        prepareUI()

        // Do any additional setup after loading the view.
    }
    
    func prepareUI(){
        self.navigationController?.isNavigationBarHidden = true
        userDescriptionField.isEditable = false
        
        //Makes the profile picture pretty
        profilePic.layer.cornerRadius = 10.0
        profilePic.layer.masksToBounds = true
        profilePic.layer.borderWidth = 4.0
        profilePic.layer.borderColor = (UIColor.white).cgColor
    }
    
    func retrieveUser(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        ref.child("users").child(uid).observe(DataEventType.value, with: { (snapshot) in
            let dictionary = snapshot.value as? [String: AnyObject]
            
            self.usernameLabel.text = dictionary!["username"]! as? String
            self.userDescriptionField.text = dictionary!["profileDescription"]! as? String
            
            let profilePicURL = dictionary!["profilePicURL"]! as? String
            
            if profilePicURL != "default"{
                let picRef = Storage.storage().reference(forURL: profilePicURL!)
                picRef.getData(maxSize: 1024*1024, completion: { (data, error) in
                    if error != nil{
                        print("Download Error")
                    } else{
                        self.profilePic.image = UIImage(data: data!)
                    }
                })
            }
            else{
                self.profilePic.image = #imageLiteral(resourceName: "defaultProfile")
            }
        })
    }
    
    @IBAction func manageCourses(_ sender: Any) {
        performSegue(withIdentifier: "courseManager", sender: self)
    }
    
    @IBAction func logout(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        performSegue(withIdentifier: "goToLogin", sender: Any?.self)
    }
    
}
