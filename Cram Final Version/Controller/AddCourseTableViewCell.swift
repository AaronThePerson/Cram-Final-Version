//
//  AddCourseTableViewCell.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 3/28/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit

class AddCourseTableViewCell: UITableViewCell {

    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var courseCodeLabel: UILabel!
    @IBOutlet weak var profLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
