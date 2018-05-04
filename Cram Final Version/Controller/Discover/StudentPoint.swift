//
//  StudentPoint.swift
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
