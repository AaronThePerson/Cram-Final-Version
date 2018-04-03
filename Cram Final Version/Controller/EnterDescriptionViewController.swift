//
//  EnterDescriptionViewController.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 3/28/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class EnterDescriptionViewController: UIViewController
{
    
    @IBOutlet weak var profileDescriptionField: UITextView!
    
    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueButton(_ sender: Any) {
        
        guard let profileText = profileDescriptionField.text else{
            fatalError("Could not assign text")
        }
        ref.child("user").child(uid!).updateChildValues(["Description": profileText])
        
        performSegue(withIdentifier: "goToAddCourses", sender: Any?.self)
    }

}
