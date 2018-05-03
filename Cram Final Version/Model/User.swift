//
//  User.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 3/28/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import MapKit

class User: NSObject {
    var uid: String?
    var username: String?
    var university: String?
    var major: String?
    var profileDescription: String?
    var profilePic: UIImage?
    var courses: [Course] = []
    var location: CLLocation?
    var distance: Double?
    var friends: [Friend] = []
    var groups: [Group] = []
 
    public func writeData(){  // Used to test snapshot parsing from firebase query results
        print("uid: " + uid!)
        print("username: " + username!)
        print("university: " + university!)
        print("major: " + major!)
        print("courses: ")
//        print(courses?.count)
//        let courseNum: Int = (courses?.count)!
//        for i in 0..<courseNum{
//            print("course name: " + courses![i].courseName!)
//        }
    }
}
