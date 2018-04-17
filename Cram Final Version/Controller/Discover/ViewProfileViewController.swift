//
//  ViewProfileViewController.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 4/17/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit

class ViewProfileViewController: UIViewController {

    @IBOutlet weak var uidLabel: UILabel!
    
    var uid: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        uidLabel.text = uid
    }
    
    @IBAction func BackToDiscover(_ sender: Any) {
        performSegue(withIdentifier: "backToSearching", sender: Any?.self)
    }
    

}
