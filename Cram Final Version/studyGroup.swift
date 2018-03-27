//
//  studyGroup.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 3/27/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import Foundation
import UIKit

class studyGroup{
    var groupName: String
    var members: [user]
    
    init?(groupName: String, members: [user]) {
        self.groupName = groupName
        self.members = members
    }
    
}
