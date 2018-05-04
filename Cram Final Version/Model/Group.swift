//
//  Group.swift
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
//  Created by Aaron Speakman on 4/26/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit

class Group: NSObject {
    var groupName: String
    var groupID: String
    var members: [Friend]?
    var lastMessage: String?
    var timestamp: Date?
    
    init(groupName: String, groupID: String) {
        self.groupName = groupName
        self.groupID = groupID
    }
    
    init(groupName: String, groupID: String, members: [Friend]) {
        self.groupName = groupName
        self.groupID = groupID
        self.members = members
    }
    
    init(groupName: String, groupID: String, members: [Friend], lastMessage: String, timestamp: Date) {
        self.groupName = groupName
        self.groupID = groupID
        self.members = members
        self.lastMessage = lastMessage
        self.timestamp = timestamp
    }
    
}
