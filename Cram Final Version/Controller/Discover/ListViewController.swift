//
//  ListViewController.swift
//  Cram Final Version
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
//
//  Created by Aaron Speakman on 4/4/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import CoreLocation

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var userList: UITableView!
    
    var currentLocation = CLLocation()
    var currentUser: User?
    var otherUsers = [User]()
    var viewProfileUID: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userList.delegate = self
        userList.dataSource = self
        let nib = UINib(nibName: "ListViewTableViewCell", bundle: nil)
        userList.register(nib, forCellReuseIdentifier: "discoveryCell")
    }
    
    func calculateDistance(otherLocation: CLLocation)->Double{
        let distance = otherLocation.distance(from: currentLocation)
        return (distance/1609.34)
    }
    
    func resetToNil(){
        currentLocation = CLLocation()
        otherUsers = []
    }
    
    func resetUsersArray(){
        otherUsers = []
        userList.reloadData()
    }
    
    func setCurrentUserLocation(userLocation: CLLocation){
        currentLocation = userLocation
    }
    
    func addUser(addedUser: User){
        addedUser.distance = calculateDistance(otherLocation: addedUser.location!)
        otherUsers.append(addedUser)
        otherUsers = otherUsers.sorted(by: {$0.distance! < $1.distance!})
        userList.reloadData()
    }
    
    func setCurrentUser(someUser: User){
        currentUser = someUser
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otherUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIndentifier = "discoveryCell"
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as? ListViewTableViewCell else{
            fatalError("Cell could not be instantiated")
        }
        
        cell.textLabel?.text = otherUsers[indexPath.row].username
        cell.detailTextLabel?.text = String(format: "%.3f", otherUsers[indexPath.row].distance!) + " miles"
        cell.accessoryType = UITableViewCellAccessoryType.detailButton
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "viewProfile") as! ViewProfileViewController
        vc.otherUser = otherUsers[indexPath.row]
        vc.currentUser = currentUser
        self.show(vc, sender: self)
    }

}
