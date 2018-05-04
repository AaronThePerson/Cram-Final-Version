//
//  AddCourseViewController.swift
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
//  Created by Aaron Speakman on 4/10/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase

class AddCourseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var courseTable: UITableView!
    
    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
    var courses = [Course]()
    var uid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userHandler()
        courseTable.rowHeight = 90
        fetchCourses()
    }
    
    func userHandler(){  //check if user is signed in
        if Auth.auth().currentUser != nil{
            let appUser = Auth.auth().currentUser
            uid = appUser?.uid
        }
        else{
            print("User is not signed in.")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIndentifier = "AddCourseTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as? AddCourseTableViewCell else{
            fatalError("Cell could not be instantiated")
        }
        
        let someCourse = courses[indexPath.row]
        cell.courseNameLabel.text = someCourse.courseName
        cell.courseCodeLabel.text = someCourse.courseCode
        cell.profLabel.text = someCourse.prof
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let id = self.courses[indexPath.row].courseID
            let toBeDeleted = ref.child("users").child(uid!).child("courses").child(id!)
            toBeDeleted.removeValue()
            self.courses.remove(at: indexPath.row)
            self.courseTable.reloadData()
        }
    }
    
    private func fetchCourses() {  //get courses from firebase
        if Auth.auth().currentUser != nil{
            ref.child("users").child(self.uid!).child("courses").observe(.childAdded, with: { (snapshot) in
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
    }
    
    func addCourse() {
        let courseCollect = UIAlertController(title: "Add Course", message: "", preferredStyle: UIAlertControllerStyle.alert)
        courseCollect.addTextField { (courseNameField) in
            courseNameField.placeholder = "Course Name"
        }
        courseCollect.addTextField { (courseCodeField) in
            courseCodeField.placeholder = "Course Code"
        }
        courseCollect.addTextField { (profField) in
            profField.placeholder = "Professor"
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (cancel) in}
        let addButton = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) { (add) in
            
            guard let courseName = (courseCollect.textFields?[0].text), let courseCode = (courseCollect.textFields?[1].text), let prof = (courseCollect.textFields?[2].text)  else {
                return
            }
            
            let courseNameEntry = self.ref.child("users").child(self.uid!).child("courses").childByAutoId()
            let values = ["courseName": courseName, "courseCode" : courseCode, "prof" : prof]
            courseNameEntry.updateChildValues(values) { (addCourseError, ref) in
                if addCourseError != nil{
                    print(addCourseError!)
                    return
                }
            }
        }
        
        courseCollect.addAction(cancelButton)
        courseCollect.addAction(addButton)
        
        present(courseCollect, animated: true, completion: nil)
    }
    
    @IBAction func AddButton(_ sender: Any) {
        addCourse()
        self.courseTable.reloadData()
    }
    
    @IBAction func DoneButton(_ sender: Any) {
        performSegue(withIdentifier: "goToApp", sender: self)
    }
    
}
