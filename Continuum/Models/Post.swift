//
//  Post.swift
//  Continuum
//
//  Created by Alex Kennedy on 10/6/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

struct PostStrings {
    static let typeKey = "Post"
    static let captionKey = "caption"
    static let timestampKey = "timestamp"
    static let commentsKey = "comments"
    static let photoKey = "photo"
    static let commentCountKey = "commentCount"
}

class Post {
    
    var photoData: Data?
    var timestamp: Date
    var commentCount: Int
    var caption: String
    var comments: [Comment]
    let recordID: CKRecord.ID
    
    var photo: UIImage? {
        get {
            guard let photoData = photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    var imageAsset: CKAsset? {
        get {
            let temporaryDirectory = NSTemporaryDirectory()
            let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
            let fileURL = temporaryDirectoryURL.appendingPathComponent(recordID.recordName).appendingPathExtension("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch let error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    
    init(timestamp: Date = Date(), caption: String, commentCount: Int = 0, comments: [Comment] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), photo: UIImage) {
        
        self.timestamp = timestamp
        self.caption = caption
        self.commentCount = commentCount
        self.comments = comments
        self.recordID = recordID
        self.photo = photo
        
    }
    
    init?(ckRecord: CKRecord) {
        do {
            guard let caption = ckRecord[PostStrings.captionKey] as? String,
                let timestamp = ckRecord[PostStrings.timestampKey] as? Date,
                let photoAsset = ckRecord[PostStrings.photoKey] as? CKAsset,
                let commentCount = ckRecord[PostStrings.commentCountKey] as? Int
                else { return nil }
            
            let photoData = try Data(contentsOf: photoAsset.fileURL)
            self.caption = caption
            self.timestamp = timestamp
            self.photoData = photoData
            self.recordID = ckRecord.recordID
            self.commentCount = commentCount
            self.comments = []
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            return nil
        }
    }
    
}

// MARK: - extensions
extension Post: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        if caption.contains(searchTerm) {
            return true
        } else {
            for comment in comments {
                if comment.matches(searchTerm: searchTerm) {
                    return true
                }
            }
        }
        return false
    }
}

