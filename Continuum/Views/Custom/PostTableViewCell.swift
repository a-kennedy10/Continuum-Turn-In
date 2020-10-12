//
//  PostTableViewCell.swift
//  Continuum
//
//  Created by Alex Kennedy on 10/6/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    // MARK: - outlets
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postCaptionLabel: UILabel!
    @IBOutlet weak var postCommentCountLabel: UILabel!
    
    // MARK: - properties
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        postImageView.image = post?.photo
        postCaptionLabel.text = post?.caption
        postCommentCountLabel.text = "Comments: \(post?.commentCount ?? 0)"
    }
}
