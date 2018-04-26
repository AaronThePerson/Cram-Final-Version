//
//  ChatLogTableViewController.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 4/4/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import MessageUI

class ChatLogTableViewController: UITableViewController {

    var groups = ["Group 1", "Group 2", "Group 3", "Group 4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        cell.textLabel?.text = "Group " + String(indexPath.row + 1)
        cell.detailTextLabel?.text = "This is a test"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToChatLog", sender: Any?.self)
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToChatLog"{
            var nav = segue.destination as! UINavigationController
            let targetController = nav.topViewController as! ChatLogViewController
        }}


}
