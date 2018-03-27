//
//  LoginViewController.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 3/24/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func login(_ sender: Any) {
        
        
        performSegue(withIdentifier: "goToApp", sender: Any?.self)
    }
    @IBAction func signUp(_ sender: Any) {
        performSegue(withIdentifier: "goToSignUp", sender: Any?.self)
    }
    
}

