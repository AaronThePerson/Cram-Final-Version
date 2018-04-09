//
//  Filter.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 4/8/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit

class Filter: NSObject {
    var distance: Int?
    var university: Bool?
    var major: Bool?
    var selectedCourses: [Course]?
    
    init(distance: Int, university: Bool, major: Bool) {
        self.distance = distance
        self.university = university
        self.major = major
    }
}
