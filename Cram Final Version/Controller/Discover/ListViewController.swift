//
//  ListViewController.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 4/4/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import CoreLocation

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var userList: UITableView!
    
    var currentLocation = CLLocation()
    var otherUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userList.delegate = self
        userList.dataSource = self
        let nib = UINib(nibName: "ListViewTableViewCell", bundle: nil)
        userList.register(nib, forCellReuseIdentifier: "discoveryCell")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resetToNil(){
        currentLocation = CLLocation()
        otherUsers = []
    }
    
    func setCurrentUserLocation(userLocation: CLLocation){
        currentLocation = userLocation
    }
    
    func addUser(addedUser: User){
        otherUsers.append(addedUser)
        userList.reloadData()
    }
    
    func calculateDistance(otherlocation: CLLocation) -> Double{
        let distance = otherlocation.distance(from: currentLocation)
        return (distance/1609.34)
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
        cell.detailTextLabel?.text = String(format: "%.3f", calculateDistance(otherlocation: otherUsers[indexPath.row].location!)) + " miles"
        cell.accessoryType = UITableViewCellAccessoryType.detailButton
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("tapped")
    }

}
