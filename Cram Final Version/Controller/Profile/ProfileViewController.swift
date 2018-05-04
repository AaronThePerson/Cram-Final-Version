//
//  ProfileViewController.swift
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

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileManager: UITableView!
    
    let cellText = ["Manage Courses","Manage Friends", "Manage Posts", "Change Profile Picture", "Change Profile Description", "Change Major", "Change University", "Logout", "Change Username", "Change Email", "Change Password"]
    
    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
    var userDescription: String?
    
    var changeType: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveUser()
        prepareUI()

        // Do any additional setup after loading the view.
    }
    
    func prepareUI(){
        self.navigationController?.isNavigationBarHidden = true
        
        //Makes the profile picture pretty
        profilePic.layer.cornerRadius = 10.0
        profilePic.layer.masksToBounds = true
        profilePic.layer.borderWidth = 4.0
        profilePic.layer.borderColor = (UIColor.white).cgColor
    }
    
    func retrieveUser(){  //retrieve necerssary user data from firebase
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        ref.child("users").child(uid).observe(DataEventType.value, with: { (snapshot) in
            let dictionary = snapshot.value as? [String: AnyObject]
            
            self.usernameLabel.text = dictionary!["username"]! as? String
            
            self.userDescription = dictionary!["profileDescription"]! as? String
            
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "generalManager"{
            let vc = segue.destination as! ProfileChangesViewController
            vc.changeType = changeType
        }
        else if segue.identifier == "changeProfileTable"{
            let vc = segue.destination as! ProfileChangesListViewController
            
            if changeType == "Manage Posts"{
                vc.changeType = "Manage Posts"
            }
            else{
                vc.changeType = "Manage Posts"
            }
            vc.changeType = changeType
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Manage Profile"
            
        }
        else if section == 1{
            return "Manage Account"
        }
        else{
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 7
        }
        else if section == 1 {
            return 4
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! ProfileManagerCellTableViewCell
        
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        if indexPath.section == 0{
            cell.textLabel?.text = cellText[indexPath.row]
        }
        else{
            cell.textLabel?.text = cellText[indexPath.row+7]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {  //logic to send to modification view controllers
        self.profileManager.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0{
            if indexPath.row == 0{
                performSegue(withIdentifier: "courseManager", sender: Any?.self)
            }
            else if indexPath.row == 1{
                changeType = "Manage Friends"
                performSegue(withIdentifier: "changeProfileTable", sender: self)
            }
            else if indexPath.row == 2{
                changeType = "Manage Posts"
                performSegue(withIdentifier: "changeProfileTable", sender: self)
            }
            else if indexPath.row == 3{
                changeType = "Change Profile Picture"
                performSegue(withIdentifier: "generalManager", sender: self)
            }
            else if indexPath.row == 4{
                changeType = "Change Profile Description"
                performSegue(withIdentifier: "generalManager", sender: self)
            }
            else if indexPath.row == 5{
                changeType = "Change Major"
                performSegue(withIdentifier: "generalManager", sender: self)
            }
            else if indexPath.row == 6{
                changeType = "Change University"
                performSegue(withIdentifier: "generalManager", sender: self)
            }
        }
        else if indexPath.section == 1{
            if indexPath.row == 0 {
                if Auth.auth().currentUser != nil{
                    ref.child("locations").child((Auth.auth().currentUser?.uid)!).removeValue()
                    ref.child("user").child((Auth.auth().currentUser?.uid)!).removeAllObservers()
                    try! Auth.auth().signOut()
                    if let storyboard = self.storyboard{
                        let vc = storyboard.instantiateInitialViewController()
                        self.present(vc!, animated: false, completion: nil)
                    }
                }
            }
            else if indexPath.row == 1{
                changeType = "Change Username"
                performSegue(withIdentifier: "generalManager", sender: self)
            }
            else if indexPath.row == 2{
                changeType = "Change Email"
                performSegue(withIdentifier: "generalManager", sender: self)
            }
            else if indexPath.row == 3{
                changeType = "Change Password"
                performSegue(withIdentifier: "generalManager", sender: self)
            }
        }
    }
}
