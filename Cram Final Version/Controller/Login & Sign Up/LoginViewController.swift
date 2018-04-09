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

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func prepareUI(){
        //Rounds login button
        loginButton.layer.cornerRadius = 5
        
        //Allows keyboard to dismiss when touching outside keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: (#selector(UIView.endEditing(_:)))))
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint.init(x: 0, y: 150), animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
    }
    

    @IBAction func login(_ sender: Any) {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (userApp, error) in
            if error != nil{
                self.errorLabel.text = "Incorrect Email or Password"
                self.errorLabel.isHidden = false
                return
            }
            else{
                self.performSegue(withIdentifier: "goToApp", sender: Any?.self)
            }
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        performSegue(withIdentifier: "goToSignUp", sender: Any?.self)
    }
    
}

