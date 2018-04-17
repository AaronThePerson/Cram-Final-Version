//
//  StudentPoint.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 4/16/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import MapKit

class StudentPoint: NSObject, MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var uid: String?
    
    init(username: String, distance: String, uid: String, location: CLLocation) {
        self.coordinate = location.coordinate
        self.title = username
        self.subtitle = distance
        self.uid = uid
    }
    
    
    
}
