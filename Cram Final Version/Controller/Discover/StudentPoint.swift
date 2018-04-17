//
//  StudentPoint.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 4/16/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import MapKit

class StudentPoint: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var uid: String?
    
    init(username: String, uid: String, location: CLLocation) {
        self.coordinate = location.coordinate
        self.title = username
        self.uid = uid
    }
    
    
    
}
