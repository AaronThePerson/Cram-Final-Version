//
//  Friend.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 4/21/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit

class Friend: NSObject {
    var uid: String
    var username: String
    
    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
    }
}
