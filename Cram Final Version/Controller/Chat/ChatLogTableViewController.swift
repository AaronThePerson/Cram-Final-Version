//
//  ChatLogTableViewController.swift
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
//  Created by Aaron Speakman on 4/4/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase

class ChatLogTableViewController: UITableViewController, NewGroupHandler {

    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
    
    var groups: [Group] = []
    var selectedGroup: Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadGroups()
    }
    
    func reloadGroups() {  //get groups from Firebase
        groups = []
        getUserGroups{
            let num: Int = self.groups.count
            for i in 0..<num{
                self.getGroupData(groupID: self.groups[i].groupID, groupNumber: i, completion: { (someGroup) in
                    self.groups[i] = someGroup
                    self.tableView.reloadData()
                })
            }
        }
    }

    func getUserGroups(completion: @escaping ()->Void){  //gets groups a user has
        ref.child("users").child((Auth.auth().currentUser?.uid)!).child("groups").observe(.value, with: { (snapshot) in
            let snapGroups = snapshot.children
            while let groupKey = snapGroups.nextObject() as? DataSnapshot{
                if let groupDictionary = groupKey.value as? [String: AnyObject]{
                    let id = groupKey.key
                    let groupName = groupDictionary["groupName"] as? String
                    self.groups.append(Group(groupName: groupName!, groupID: id))
                }
            }
            completion()
        }, withCancel: nil)
    }
    
    func getGroupData(groupID: String, groupNumber: Int, completion: @escaping (Group)->Void){ //get data for a group
        ref.child("groups").child(groupID).observeSingleEvent(of: .value) { (snapshot) in
            
            var groupName: String = ""
            var lastMessage: String = ""
            var timestamp: Date?
            var members: [Friend] = []
            var someGroup: Group?
            
            let snapGroups = snapshot.children
            while let data = snapGroups.nextObject() as? DataSnapshot{
                switch data.key{
                case "groupName":
                    groupName = (data.value as? String)!
                case "lastMessage":
                    lastMessage = (data.value as? String)!
                case "timestamp":
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    timestamp = dateFormatter.date(from: (data.value as? String)!)!
                case "members":
                    let memberSnap = data.children
                    while let memberData = memberSnap.nextObject() as? DataSnapshot{
                        let memberId = memberData.key
                        let memberName = memberData.value as? String
                        let friend = Friend(uid: memberId, username: memberName!)
                        members.append(friend)
                    }
                default: break
                }
                if timestamp == nil || lastMessage == ""{
                    someGroup = Group(groupName: groupName, groupID: groupID, members: members)
                }
                else{
                    someGroup = Group(groupName: groupName, groupID: groupID, members: members, lastMessage: lastMessage, timestamp: timestamp!)
                }
            }
            completion(someGroup!)
        }
    }
    
    //for functions to handle general table view set up
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatLogCell", for: indexPath)
        
        cell.textLabel?.text = groups[indexPath.row].groupName
        cell.detailTextLabel?.text = groups[indexPath.row].lastMessage
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedGroup = self.groups[indexPath.row]
        performSegue(withIdentifier: "goToChatLog", sender: Any?.self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let groupToRemove = groups[indexPath.row]
            ref.child("users").child((Auth.auth().currentUser?.uid)!).child("groups").child(groupToRemove.groupID).removeValue()
            if (groupToRemove.members?.count)! <= 1{
                ref.child("groups").child(groupToRemove.groupID).removeValue()
                ref.child("chats").child(groupToRemove.groupID).removeValue()
            }
            else{
                ref.child("groups").child(groupToRemove.groupID).child("members").child((Auth.auth().currentUser?.uid)!).removeValue()
            }
            
            groups.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }

    @IBAction func createGroup(_ sender: Any) {
        performSegue(withIdentifier: "showCreateGroup", sender: Any?.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {  //called before the app segues to another view
        
        if segue.identifier == "showCreateGroup"{
            let vc = segue.destination as! CreateGroupViewController
            vc.delegate = self
        }
        else if segue.identifier == "goToChatLog"{
            let vc = segue.destination as! ChatLogViewController
            vc.selectedGroup = selectedGroup
        }
    }

    
}
