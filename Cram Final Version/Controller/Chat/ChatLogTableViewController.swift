//
//  ChatLogTableViewController.swift
//  Cram Final Version
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
    
    func reloadGroups() {
        groups = []
        getUserGroups{
            let num: Int = self.groups.count
            for i in 0..<num{
                self.getGroupData(groupID: self.groups[i].groupID, groupNumber: i, completion: { (someGroup) in
                    self.groups[i] = someGroup
                })
            }
            self.tableView.reloadData()
        }
    }

    func getUserGroups(completion: @escaping ()->Void){
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
    
    func getGroupData(groupID: String, groupNumber: Int, completion: @escaping (Group)->Void){
        ref.child("groups").child(groupID).observeSingleEvent(of: .value) { (snapshot) in
            
            var groupName: String = ""
            var lastMessage: String = ""
            var timestamp: Date?
            var members: [Friend] = []
            var someGroup: Group?
            
            let snapGroups = snapshot.children
            while let data = snapGroups.nextObject() as? DataSnapshot{
                print(snapshot)
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
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.groups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatLogCell", for: indexPath)
        
        cell.textLabel?.text = groups[indexPath.row].groupName
        cell.detailTextLabel?.text = groups[indexPath.row].lastMessage
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(groups[indexPath.row].groupName)
        self.selectedGroup = self.groups[indexPath.row]
        performSegue(withIdentifier: "goToChatLog", sender: Any?.self)
    }

    @IBAction func createGroup(_ sender: Any) {
        performSegue(withIdentifier: "showCreateGroup", sender: Any?.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
