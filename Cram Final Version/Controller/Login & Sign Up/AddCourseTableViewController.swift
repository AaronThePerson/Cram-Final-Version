//
//  AddCourseTableViewController.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 3/27/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AddCourseTableViewController: UITableViewController {
    
    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
    var courses = [Course]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 90
        fetchCourses()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let id = self.courses[indexPath.row].courseID
            let toBeDeleted = ref.child("users").child((Auth.auth().currentUser?.uid)!).child("courses").child(id!)
            toBeDeleted.removeValue()
            self.courses.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    private func fetchCourses() {
        
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("courses").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                print(snapshot)
                let someCourse = Course()
                someCourse.courseID = snapshot.key
                someCourse.courseName = (dictionary["courseName"] as? String)!
                someCourse.courseCode = (dictionary["courseCode"] as? String)!
                someCourse.prof = (dictionary["prof"] as? String)!
                self.courses.append(someCourse)
                self.tableView.reloadData()
            }
            
        }, withCancel: nil)
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
            
            let courseNameEntry = self.ref.child("users").child((Auth.auth().currentUser?.uid)!).child("courses").childByAutoId()
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
    
    @IBAction func addClasse(_ sender: Any) {
        addCourse()
        self.tableView.reloadData()
    }
    
    @IBAction func toApp(_ sender: Any) {
        performSegue(withIdentifier: "goToApp", sender: self)
    }

}
