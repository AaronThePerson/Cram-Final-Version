//
//  User.swift
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
