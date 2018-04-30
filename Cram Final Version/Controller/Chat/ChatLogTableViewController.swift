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
    var selectedGroupNum = 0
    
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
                self.getGroupData(groupID: self.groups[i].groupID, groupNumber: i)
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
    
    func getGroupData(groupID: String, groupNumber: Int){
        ref.child("groups").child(groupID).observeSingleEvent(of: .value) { (snapshot) in
            let snapGroups = snapshot.children
            while let data = snapGroups.nextObject() as? DataSnapshot{
                switch data.key{
                case "groupName":
                    self.groups[groupNumber].groupName = (data.value as? String)!
                case "lastMessage":
                    self.groups[groupNumber].lastMessage = (data.value as? String)!
                case "timestamp":
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    self.groups[groupNumber].timestamp = dateFormatter.date(from: (data.value as? String)!)!
                case "members":
                    let memberSnap = data.children
                    while let memberData = memberSnap.nextObject() as? DataSnapshot{
                        let memberId = memberData.key
                        let memberName = memberData.value as? String
                        self.groups[groupNumber].members?.append(Friend(uid: memberId, username: memberName!))
                    }
                default: break
                }
            }
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
        selectedGroupNum = indexPath.row
        print(indexPath.row)
        print(groups[indexPath.row].groupName)
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
            vc.selectedGroup = groups[selectedGroupNum]
        }
    }

    
}
