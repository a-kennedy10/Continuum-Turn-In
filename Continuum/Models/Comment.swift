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
    weak var post: Post?
    
    let recordID: CKRecord.ID
    var postReference: CKRecord.Reference? {
        guard let post = post else { return nil }
        return CKRecord.Reference(recordID: post.recordID, action: .deleteSelf)
    }
    
    init(text: String, timestamp: Date = Date(), post: Post, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.recordID = recordID
    }
    
    convenience init?(ckRecord: CKRecord, post: Post) {
        guard let text = ckRecord[CommentStrings.textKey] as? String,
            let timestamp = ckRecord[CommentStrings.timestampKey] as? Date else { return nil }
            self.init(text: text, timestamp: timestamp, post: post, recordID: ckRecord.recordID)
    }
    
    
}

// MARK: - extensions
extension Comment: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        return text.contains(searchTerm)
    }
}
