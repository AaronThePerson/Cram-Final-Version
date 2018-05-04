//
//  ProfileChangesViewController.swift
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
//  Created by Aaron Speakman on 4/30/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase

class ProfileChangesViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var profileTextField: UITextView!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var changeProfileButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
    
    var changeType: String?
    var profileDescription: String?
    var photoChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    func prepareUI(){
        if changeType == "Change Profile Picture"{
            profilePic.isHidden = false
            changeProfileButton.isHidden = false
        }
        else if changeType == "Change Profile Description"{
            profileTextField.isHidden = false
            profileTextField.text = profileDescription
        }
        else if changeType == "Change Major"{
            textField1.isHidden = false
            textField1.placeholder = "New Major"
        }
        else if changeType == "Change University"{
            textField1.isHidden = false
            textField1.placeholder = "New University"
        }
        else if changeType == "Change Username"{
            textField1.isHidden = false
            textField1.placeholder = "New Username"
            textField1.textContentType = UITextContentType.username
        }
        else if changeType == "Change Email"{
            textField1.isHidden = false
            textField1.placeholder = "New Email"
            textField1.textContentType = UITextContentType.emailAddress
        }
        else if changeType == "Change Password"{
            textField1.isHidden = false
            textField1.placeholder = "New Password"
            textField1.textContentType = UITextContentType.password
            textField2.isHidden = false
            textField2.placeholder = "Re-Enter New Password"
            textField2.textContentType = UITextContentType.password
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {  //keyboard release
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {  //image picker release
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            profilePic.image = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            profilePic.image = originalImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveChanges(_ sender: Any) {  //updates changes to firebase depending on changetype from previous view
        dismiss(animated: true, completion: nil)
        if changeType == "Change Profile Picture"{
            if self.photoChanged{
                let uid: String = (Auth.auth().currentUser?.uid)!
                let storageRef = Storage.storage().reference().child("profile_images").child("\(uid)profileImage.jpeg")
                
                if let uploadData = UIImageJPEGRepresentation(self.profilePic.image!, 0.1){
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, uploadError) in
                        if uploadError != nil{
                            print(uploadError!)
                            return
                        }
                        let photoURL = metadata?.downloadURL()?.absoluteString
                        
                        self.ref.child("users").child((Auth.auth().currentUser?.uid)!).child("photoPicURL").setValue(photoURL)
                    })
                }
            }
        }
        else if changeType == "Change Profile Description"{
            let text = profileTextField.text.trimmingCharacters(in: CharacterSet.whitespaces)
            if text != ""{
                ref.child("users").child((Auth.auth().currentUser?.uid)!).child("profileDescription").setValue(profileTextField.text)
                performSegue(withIdentifier: "backToProfile", sender: Any?.self)
            }
            else{
                errorAlert(alertTitle: "No Profile Description", alertText: "Please add a profile description.")
            }
        }
        else if changeType == "Change Major"{
            let text = textField1.text?.trimmingCharacters(in: CharacterSet.whitespaces)
            if text != ""{
                ref.child("users").child((Auth.auth().currentUser?.uid)!).child("major").setValue(profileTextField.text)
                performSegue(withIdentifier: "backToProfile", sender: Any?.self)
            }
            else{
                errorAlert(alertTitle: "No Major", alertText: "Please add a major.")
            }
        }
        else if changeType == "Change University"{
            let text = textField1.text?.trimmingCharacters(in: CharacterSet.whitespaces)
            if text != ""{
                ref.child("users").child((Auth.auth().currentUser?.uid)!).child("major").setValue(profileTextField.text)
                performSegue(withIdentifier: "backToProfile", sender: Any?.self)
            }
            else{
                errorAlert(alertTitle: "No University", alertText: "Please add a university.")
            }
        }
        else if changeType == "Change Username"{
            let text = textField1.text?.trimmingCharacters(in: CharacterSet.whitespaces)
            if text != ""{
                ref.child("users").child((Auth.auth().currentUser?.uid)!).child("major").setValue(profileTextField.text)
                performSegue(withIdentifier: "backToProfile", sender: Any?.self)
            }
            else{
                errorAlert(alertTitle: "No University", alertText: "Please add a university.")
            }
        }
        else if changeType == "Change Email"{
            let text = textField1.text?.trimmingCharacters(in: CharacterSet.whitespaces)
            if text != ""{
                ref.child("users").child((Auth.auth().currentUser?.uid)!).child("email").setValue(profileTextField.text)
                Auth.auth().currentUser?.updateEmail(to: text!, completion: { (error) in
                    print(error!)
                })
                performSegue(withIdentifier: "backToProfile", sender: Any?.self)
            }
            else{
                errorAlert(alertTitle: "No Email", alertText: "Please add an email.")
            }
        }
        else if changeType == "Change Password"{
            var canChangePassword: Bool = true
            
            if (textField1.text != textField2.text && textField1.text != nil && textField2.text != nil){
                errorLabel.text = "Passwords do not match."
                errorLabel.isHidden = false
                canChangePassword = false
                return
            }
            else{
                let passwordCharacters = NSCharacterSet(charactersIn: textField1.text!)
                if ((textField1.text?.count)! < 8){
                    errorLabel.text = "Passwords too short."
                    errorLabel.isHidden = false
                    canChangePassword = false
                    return
                }
                else if(CharacterSet.urlPasswordAllowed.isSuperset(of: passwordCharacters as CharacterSet)){
                    errorLabel.isHidden = true
                    canChangePassword = true
                }
                else{
                    errorLabel.text = "Passwords contains illegal characters"
                    errorLabel.isHidden = false
                    canChangePassword = false
                    return
                }
            }
            
            if canChangePassword{
                Auth.auth().currentUser?.updatePassword(to: textField1.text!, completion: nil)
            }
        }
        
    }
    
    @IBAction func BackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func errorAlert(alertTitle: String, alertText: String){
        let errorPopup = UIAlertController(title: alertTitle, message: alertText, preferredStyle: UIAlertControllerStyle.alert)
        errorPopup.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(errorPopup, animated: true, completion: nil)
    }
    
}
