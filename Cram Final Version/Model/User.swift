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
    var courses: [Course]?
    var location: CLLocation?
    
}
