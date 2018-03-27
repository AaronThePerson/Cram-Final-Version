//
//  SignUpViewController.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 3/27/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUp(_ sender: Any) {
        
        guard let signUpEmail = email.text, let signUpPassword = password.text else {
            print("Not valid.")
            return
        }
        
        
        Auth.auth().createUser(withEmail: signUpEmail, password: signUpPassword) { (userApp, error) in
            if error != nil{
                print("error")
                return
            }
            //successfully authenticate user
            
            
        }
        performSegue(withIdentifier: "addClasses", sender: Any?.self)
    }
    
}
