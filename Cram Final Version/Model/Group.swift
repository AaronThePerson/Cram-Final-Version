//
//  Group.swift
//  Cram Final Version
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
