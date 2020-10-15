//
//  Comment.swift
//  Continuum
//
//  Created by Alex Kennedy on 10/6/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

struct CommentStrings {
    static let recordType = "Comment"
    static let textKey = "text"
    static let timestampKey = "timestamp"
    static let postReferenceKey = "post"
}

class Comment {
    let text: String
    let timestamp: Date
    
    let recordID: CKRecord.ID
    var postReference: CKRecord.Reference?
    
    init(text: String, timestamp: Date = Date(), post: Post, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), postReference: CKRecord.Reference?) {
        self.text = text
        self.timestamp = timestamp
        self.recordID = recordID
        self.postReference = postReference
        
    }
    
}

// MARK: - extensions
extension Comment {
    convenience init?(ckRecord: CKRecord, post: Post) {
    guard let text = ckRecord[CommentStrings.textKey] as? String,
        let timestamp = ckRecord[CommentStrings.timestampKey] as? Date else { return nil }
    let postReference = ckRecord[CommentStrings.postReferenceKey] as? CKRecord.Reference
    
    self.init(text: text, timestamp: timestamp, post: post, recordID: ckRecord.recordID, postReference: postReference)
    }
}

extension CKRecord {
    convenience init(comment: Comment) {
        self.init(recordType: CommentStrings.recordType, recordID: comment.recordID)
        self.setValuesForKeys([
            CommentStrings.textKey : comment.text,
            CommentStrings.timestampKey : comment.timestamp
        ])
        if let reference = comment.postReference {
            self.setValue(reference, forKey: CommentStrings.postReferenceKey)
        }
    }
}
