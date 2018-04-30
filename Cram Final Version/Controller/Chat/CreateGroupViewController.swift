//
//  CreateGroupViewController.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 4/26/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase

protocol NewGroupHandler {
    func reloadGroups()
}

class CreateGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var friendsTable: UITableView!
    @IBOutlet weak var createView: UIView!
    
    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
    
    var delegate: NewGroupHandler?
    
    var friends: [Friend] = []
    var selectedFriends: [Friend] = []
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getFriends {
            self.friendsTable.reloadData()
        }
    }
    
    func prepareUI(){
        
    }
    
    func getFriends(completion: @escaping ()->Void){
        _ = ref.child("users").child((Auth.auth().currentUser?.uid)!).child("username").observe(.value) { (snapshot) in
            self.username = snapshot.value as! String
        }
        let friendRef = ref.child("users").child((Auth.auth().currentUser?.uid)!).child("friends")
        friendRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let snapFriends = snapshot.children
            while let friendKey = snapFriends.nextObject() as? DataSnapshot{
                if let friendDictionary = friendKey.value as? [String: AnyObject]{
                    let id = friendKey.key
                    let friendsUsername = friendDictionary["username"] as? String
                    self.friends.append(Friend(uid: id, username: friendsUsername!))
                }
            }
            completion()
        }, withCancel: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Friends"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath)
        
        cell.textLabel?.text = friends[indexPath.row].username
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFriends.append(friends[indexPath.row])
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedFriends.remove(at: selectedFriends.index(of: friends[indexPath.row])!)
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
    }
    
    func addGroupToFirebase(newGroup: Group, completion: ()->Void){
        let num: Int = (newGroup.members?.count)!
        var membersDict: [String: Any] = [:]
        for i in 0..<num{
            membersDict[(newGroup.members?[i].uid)!] = newGroup.members?[i].username as AnyObject
            ref.child("users").child((newGroup.members?[i].uid)!).child("groups").child(newGroup.groupID).child("groupName").setValue(newGroup.groupName)
        }
        print(membersDict)
        ref.child("groups").child(newGroup.groupID).child("groupName").setValue(newGroup.groupName)
        ref.child("groups").child(newGroup.groupID).child("members").updateChildValues(membersDict)
        completion()
    }
    
    @IBAction func Done(_ sender: Any) {
        let groupNameCheck = groupName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if selectedFriends.count >= 1 && groupNameCheck != ""{
            selectedFriends.append(Friend(uid: (Auth.auth().currentUser?.uid)!, username: self.username!))
            let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
            let groupID = ref.child("groups").childByAutoId().key
            let newGroup = Group(groupName: groupNameCheck!, groupID: groupID, members: selectedFriends)
            addGroupToFirebase(newGroup: newGroup) {
                delegate?.reloadGroups()
                dismiss(animated: true, completion: nil)
            }
        }
        else{
            if groupNameCheck == ""{
                errorAlert(alertTitle: "No Group Name", alertText: "Add a group name.")
            }
            else if selectedFriends.count < 1{
                errorAlert(alertTitle: "No Friends Selected", alertText: "Choose members of the group.")
            }
        }
    }
    
    @IBAction func Cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func errorAlert(alertTitle: String, alertText: String){
        let errorPopup = UIAlertController(title: alertTitle, message: alertText, preferredStyle: UIAlertControllerStyle.alert)
        errorPopup.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(errorPopup, animated: true, completion: nil)
    }
    
}
