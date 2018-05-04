//
//  SignUpViewController.swift
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
//  Created by Aaron Speakman on 3/27/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate{

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var reEnterPasswordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var universityField: UITextField!
    @IBOutlet weak var majorField: UITextField!
    @IBOutlet weak var upperErrorLabel: UILabel!
    
    @IBOutlet weak var profileDescriptionField: UITextView!
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var signUPButton: UIButton!
    @IBOutlet weak var bottomErrorLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var canSignUp: Bool = false
    var photoChanged = false
    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()

    }

    func prepareUI(){
        
        //Makes the profile picture pretty
        profilePic.layer.cornerRadius = 10.0
        profilePic.layer.masksToBounds = true
        profilePic.layer.borderWidth = 4.0
        profilePic.layer.borderColor = (UIColor.white).cgColor
        
        //Sets profile pic up as button to set
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.selectProfilePic(_:)))
        tapRecognizer.delegate = self
        self.profilePic.addGestureRecognizer(tapRecognizer)
        self.profilePic.isUserInteractionEnabled = true
        
        //Rounds description and sign up button
        profileDescriptionField.layer.cornerRadius = 5
        signUPButton.layer.cornerRadius = 5
        
        //Allows keyboard to dismiss when touching outside keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: (#selector(UIView.endEditing(_:)))))
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
            scrollView.setContentOffset(CGPoint.init(x: 0, y: 250), animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {  //checks for correct input from user
        scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
        
        if (passwordField.text != reEnterPasswordField.text && passwordField.text != nil && passwordField.text != nil){
            upperErrorLabel.text = "Passwords do not match."
            upperErrorLabel.isHidden = false
            canSignUp = false
            return
        }
        else{
            if textField.textContentType == UITextContentType.password{
                let passwordCharacters = NSCharacterSet(charactersIn: textField.text!)
                if ((textField.text?.count)! < 8){
                    upperErrorLabel.text = "Passwords too short."
                    upperErrorLabel.isHidden = false
                    canSignUp = false
                    return
                }
                else if(CharacterSet.urlPasswordAllowed.isSuperset(of: passwordCharacters as CharacterSet)){
                    upperErrorLabel.isHidden = true
                    canSignUp = true
                }
                else{
                    upperErrorLabel.text = "Passwords contains illegal characters"
                    upperErrorLabel.isHidden = false
                    canSignUp = false
                    return
                }
            }
        }
        
        if (usernameField.text?.contains(" "))!{
            upperErrorLabel.text = "Usernames cannot contain spaces."
            upperErrorLabel.isHidden = false
            canSignUp = false
            return
        }
        else{
            upperErrorLabel.isHidden = true
            canSignUp = true
        }
        
    }

    func textViewDidBeginEditing(_ textView: UITextView) {  //adjusts view based on text field selected
        scrollView.setContentOffset(CGPoint.init(x: 0, y: 550), animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {  //sets up
        scrollView.setContentOffset(CGPoint.init(x: 0, y: 300), animated: true)
        if (profileDescriptionField.text != nil){
            upperErrorLabel.isHidden = true
            canSignUp = true
        }
        else{
            upperErrorLabel.isHidden = false
            canSignUp = false
            bottomErrorLabel.text = "Enter a profile description."
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {  //handler for image picker
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            profilePic.image = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            profilePic.image = originalImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectProfilePic(_ sender: Any) {  //sets up and presents image picker
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        controller.allowsEditing = true
        
        present(controller, animated: true, completion: nil)
        photoChanged = true
    }
    
    func addUserData(uid: String, values: [String: AnyObject]){
        let usersReference = self.ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (initialWriteError, ref) in
            if initialWriteError != nil{
                print(initialWriteError!)
                return
            }
        })
    }
    
    func setupDone(email: String, password: String){
        self.performSegue(withIdentifier: "goToAddCourses", sender: Any?.self)
    }
    
    @IBAction func backToLogin(_ sender: Any) {
        performSegue(withIdentifier: "goBackToLogin", sender: Any?.self)
    }
    
    @IBAction func signUp(_ sender: Any) {  ///attempts to create a user
        
        guard let email = emailField.text, let password = passwordField.text, let username = usernameField.text, let university = universityField.text, let major = majorField.text, let profileDescription = profileDescriptionField.text else {
            print("Not valid.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (userApp, signUpError) in
            if signUpError != nil{
                self.errorAlert(alertTitle: "Sign Up Error", alertText: (signUpError?.localizedDescription)!)
                return
            }else{
                guard let uid = Auth.auth().currentUser?.uid else{
                    return
                }

                if self.photoChanged{  //with a profile picture
                    let storageRef = Storage.storage().reference().child("profile_images").child("\(uid)profileImage.jpeg")
                    
                    if let uploadData = UIImageJPEGRepresentation(self.profilePic.image!, 0.1){
                        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, uploadError) in
                            if uploadError != nil{
                                print(uploadError!)
                                return
                            }
                            let photoURL = metadata?.downloadURL()?.absoluteString
                            
                             let values = ["username": username, "email": email, "university": university, "major": major, "profileDescription": profileDescription, "profilePicURL": photoURL]
                            self.addUserData(uid: uid, values: values as [String : AnyObject])
                        })
                    }
                }
                else{  //without a profile picture
                     let values = ["username": username, "email": email, "university": university, "major": major, "profileDescription": profileDescription, "profilePicURL": "default"]
                    self.addUserData(uid: uid, values: values as [String : AnyObject])
                }

            }
        
            self.setupDone(email: email, password: password)
        }
    }
    
    func errorAlert(alertTitle: String, alertText: String){  //alert handler for firebase error
        let errorPopup = UIAlertController(title: alertTitle, message: alertText, preferredStyle: UIAlertControllerStyle.alert)
        errorPopup.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(errorPopup, animated: true, completion: nil)
    }
}
