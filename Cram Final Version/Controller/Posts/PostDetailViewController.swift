//
//  PostDetailViewController.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 4/24/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postDescriptionView: UITextView!
    
    var detailPost = Post()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }

    func prepareUI(){
        username.text = detailPost.username
        titleLabel.text = detailPost.title
        postDescriptionView.text = detailPost.postDescription
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewProfilePost"{
            
        }
    }
    
    @IBAction func viewProfile(_ sender: Any) {
        performSegue(withIdentifier: "viewProfilePost", sender: Any?.self)
    }
    @IBAction func backToPosts(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
