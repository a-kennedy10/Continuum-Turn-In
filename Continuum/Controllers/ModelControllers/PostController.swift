//
//  PostController.swift
//  Continuum
//
//  Created by Alex Kennedy on 10/6/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class PostController {
    // MARK: - singleton
    static let shared = PostController()
    
    private init() {
        subscribeToNewPosts(completion: nil)
    }
    // MARK: - source of truth
    var posts: [Post] = []
    
    
    
    // MARK: - CRUD
    func addComment(text: String, post: Post, completion: @escaping (Comment?) -> Void) {
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
        let record = CKRecord(comment: comment)
        
        CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
            
            guard let record = record else { completion(nil); return }
            let comment = Comment(ckRecord: record, post: post)
            self.incrementCommentCount(for: post, completion: nil)
            completion(comment)
        }
        
    }
    
    func createPostWith(photo: UIImage, caption: String, completion: @escaping (Post?) -> Void) {
        let newPost = Post(caption: caption, photo: photo)
        self.posts.append(newPost)
        let record = CKRecord(post: newPost)
        
        CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
            guard let record = record, let post = Post(ckRecord: record) else { completion(nil); return }
            completion(post)
        }
    }
    
    // MARK: - read
    func fetchPosts(completion: @escaping ([Post]?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: PostStrings.typeKey, predicate: predicate)
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
            guard let records = records else { completion(nil); return }
            let posts = records.compactMap{ Post(ckRecord: $0) }
            self.posts = posts
            completion(posts)
        }
    }
    
    
    func fetchComments(for post: Post, completion: @escaping ([Comment]?) -> Void) {
        let postReference = post.recordID
        let predicate = NSPredicate(format: "%K == %@", CommentStrings.postReferenceKey, postReference)
        let commentIDS = post.comments.compactMap({$0.recordID})
        
        let predicateTwo = NSPredicate(format: "NOT(recordID IN %@)", commentIDS)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicateTwo])
        
        let query = CKQuery(recordType: "Comment", predicate: compoundPredicate)
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
            guard let records = records else { completion(nil); return }
            let comments = records.compactMap{ Comment(ckRecord: $0, post: post) }
            post.comments.append(contentsOf: comments)
            completion(comments)
        }
    }
    
    
    // MARK: - update
    func incrementCommentCount(for post: Post, completion: ((Bool) -> Void)? ) {
        post.commentCount += 1
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [CKRecord(post: post)], recordIDsToDelete: nil)
        
        modifyOperation.savePolicy = .changedKeys
        modifyOperation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false)
                return
            } else {
                completion?(true)
            }
            
        }
        CKContainer.default().publicCloudDatabase.add(modifyOperation)
    }
    
    
    func subscribeToNewPosts(completion: ((Bool, Error?) -> Void)?) {
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: "Post", predicate: predicate, subscriptionID: "AllPosts", options: CKQuerySubscription.Options.firesOnRecordCreation)
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "New post added"
        notificationInfo.shouldBadge = true
        subscription.notificationInfo = notificationInfo
        
        CKContainer.default().publicCloudDatabase.save(subscription) { (subscription, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false, error)
            } else {
                completion?(true, nil)
            }
        }
    }
    
    func addSubcriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> ())? ) {
        let postRecordID = post.recordID
        let predicate = NSPredicate(format: "%K == %@", CommentStrings.postReferenceKey, postRecordID)
        let subscription = CKQuerySubscription(recordType: "Comment", predicate: predicate, subscriptionID: post.recordID.recordName, options: CKQuerySubscription.Options.firesOnRecordCreation)
        let notificationInfo = CKSubscription.NotificationInfo()
        
        notificationInfo.alertBody = "A new comment was added to a post that you follow"
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = nil
        subscription.notificationInfo = notificationInfo
        
        CKContainer.default().publicCloudDatabase.save(subscription) { (_, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false, error)
            } else {
                completion?(true, nil)
            }
        }
    }
    
    func removeSubscriptionTo(commentsForPost post: Post, completion: ((Bool) -> ())? ) {
        let subscriptionID = post.recordID.recordName
        
        CKContainer.default().publicCloudDatabase.delete(withSubscriptionID: subscriptionID) { (_, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false)
                return
            } else {
                completion?(true)
            }
        }
    }
    
    func checkForSubscription(to post: Post, completion: ((Bool) -> ())? ) {
        let subscriptionID = post.recordID.recordName
        
        CKContainer.default().publicCloudDatabase.fetch(withSubscriptionID: subscriptionID) { (subscription, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false)
                return
            }
            if subscription != nil {
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
    func toggleSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> ())? ) {
        checkForSubscription(to: post) { (isSubscribed) in
            if isSubscribed {
                self.removeSubscriptionTo(commentsForPost: post) { (success) in
                    if success {
                        print("Successfully removes the subscription to post with \(post.caption)")
                        completion?(true, nil)
                    } else {
                        print("There was an error removing the subscription to \(post.caption)")
                        completion?(false,nil)
                    }
                }
            } else {
                self.addSubcriptionTo(commentsForPost: post) { (success, error) in
                    if let error = error {
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                        completion?(false, error)
                        return
                    }
                    if success {
                        print("Successfully added subscription to post \(post.caption)")
                        completion?(true, nil)
                    } else {
                        print("Something went wrong trying to remove subscription to post \(post.caption)")
                        completion?(false, nil)
                    }
                }
            }
        }
    }
    
    
    
}
