//
//  user.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 3/27/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import Foundation
import MapKit

class user {
    var username: String
    var university: String
    var major: String
    var classes: [course]
    var location: MKMapPoint
    
    init(username: String, university: String, major: String, classes: [course], location: MKMapPoint){
        self.username = username
        self.university = university
        self.major = major
        self.classes = classes
        self.location = location
    }
    
}
