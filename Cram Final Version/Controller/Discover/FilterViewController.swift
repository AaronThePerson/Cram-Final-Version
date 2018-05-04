//
//  FilterViewController.swift
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
//  Created by Aaron Speakman on 4/8/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase

protocol SendFilter{
    func setFilter(filter: Filter)
}

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")

    @IBOutlet weak var distanceSlide: UISlider!
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var universitySwitch: UISwitch!
    @IBOutlet weak var majorSwitch: UISwitch!
    @IBOutlet weak var courseTable: UITableView!
    
    var dataFilter = Filter(distance: 5, university: false, major: false, selectedCourses: [])
    var courses = [Course]()
    var selectedCourses = [Course]()
    
    var delegate: SendFilter?
    
    @IBOutlet weak var filterWindow: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        prepareFilter()
        getUserData()
    }
    
    func prepareUI() {
        filterWindow.layer.cornerRadius = 5
        milesLabel.text =  String(Int(distanceSlide.value)) + " miles"
    }
    
    func prepareFilter(){  //loads in previous data filters state
        distanceSlide.value = Float(dataFilter.distance!)
        milesLabel.text =  String(Int(distanceSlide.value)) + " miles"
        if dataFilter.university == true{
            universitySwitch.isOn = true
        }
        else{
            universitySwitch.isOn = false
        }
        if dataFilter.major == true{
            majorSwitch.isOn = true
        }
        else{
            majorSwitch.isOn = false
        }
    }
    
    func getUserData(){  //get some course data from Firebase
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("courses").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let someCourse = Course()
                someCourse.courseID = snapshot.key
                someCourse.courseName = (dictionary["courseName"] as? String)!
                someCourse.courseCode = (dictionary["courseCode"] as? String)!
                someCourse.prof = (dictionary["prof"] as? String)!
                self.courses.append(someCourse)
                self.courseTable.reloadData()
            }
        }, withCancel: nil)
        
    }
    
    @IBAction func toggleUniversity(_ sender: Any) {
        if universitySwitch.isOn == true{
            dataFilter.university = true
        }
        else if universitySwitch.isOn == false{
            dataFilter.university = false
        }
    }
    
    @IBAction func toggleMajor(_ sender: Any) {  //
        if majorSwitch.isOn == true{
            dataFilter.major = true
        }
        else if majorSwitch.isOn == false{
            dataFilter.major = false
        }
    }
    
    //next five functions set up table view of courses
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cellIndentifier = "courseCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as? FilterCourseTableViewCell else{
            fatalError("Cell could not be instantiated")
        }
        
        cell.textLabel?.text = courses[indexPath.row].courseName
        cell.detailTextLabel?.text = courses[indexPath.row].courseCode
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        selectedCourses.append(courses[indexPath.row])
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
        let courseIndex = selectedCourses.index(of: courses[indexPath.row])
        selectedCourses.remove(at: courseIndex!)
    }
    
    @IBAction func distanceChanged(_ sender: Any) {  //called when the slider moves
        milesLabel.text =  String(Int(distanceSlide.value)) + " miles"
    }
    
    @IBAction func resetPushed(_ sender: Any) {  //resets data filter to default
        distanceSlide.value = 5
        universitySwitch.isOn = false
        majorSwitch.isOn = false
        milesLabel.text = String(Int(distanceSlide.value)) + " miles"
        
        dataFilter.distance = 5
        dataFilter.university = false
        dataFilter.major = false
        dataFilter.selectedCourses = [Course]()
    }
    
    @IBAction func doneFiltering(_ sender: Any) {  //handles sending the data filter back to previous view
        dataFilter.distance = Int(distanceSlide.value)
        dataFilter.selectedCourses = selectedCourses
        
        delegate?.setFilter(filter: dataFilter)
        dismiss(animated: true, completion: nil)
    }
    
}
