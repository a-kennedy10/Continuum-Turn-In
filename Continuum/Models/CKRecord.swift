//
//  CKRecord.swift
//  Continuum
//
//  Created by Alex Kennedy on 10/11/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

extension CKRecord {
    convenience init(post: Post) {
        self.init(recordType: PostStrings.typeKey, recordID: post.recordID)
        self.setValue(post.caption, forKey: PostStrings.captionKey)
        self.setValue(post.timestamp, forKey: PostStrings.timestampKey)
        self.setValue(post.imageAsset, forKey: PostStrings.photoKey)
        self.setValue(post.commentCount, forKey: PostStrings.commentCountKey)
    }
    
}
