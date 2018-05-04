//
//  Post.swift
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
//  Created by Aaron Speakman on 4/1/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit
import CoreLocation

class Post: NSObject {
    var postID: String?
    var title: String?
    var username: String?
    var uid: String?
    var postDescription: String?
    var timeStamp: Int64?
}
