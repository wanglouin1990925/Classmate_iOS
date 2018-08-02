//
//  PostImageTableViewCell.swift
//  Classmate
//
//  Created by Administrator on 7/13/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SDWebImage

protocol PostImageTableViewCellDelegate: NSObjectProtocol {
    func postCellLikeButtonClicked(_ index: Int, _ like_count: Int)
    func postCellCommentButtonClicked(_ post: Post)
    func postCellBookmarkButtonClicked(_ post: Post)
    func postCellReportButtonClicked(_ post: Post)
    func postCellDeleteButtonClicked(_ post: Post)
}

class PostImageTableViewCell: UITableViewCell {

    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var bookmarkImageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var reportContainerViw: UIView!
    @IBOutlet weak var deleteContainerView: UIView!
    @IBOutlet weak var toolbarView: UIView!
    
    let databaseReference = Database.database().reference()
    let storageReference = Storage.storage().reference()
    
    var delegate: PostImageTableViewCellDelegate?
    var post: Post?
    var index: Int = -1
    
    var bookmarkKey = ""
    var likeKey = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCell(_ post: Post, index: Int) {
        self.post = post
        self.index = index
        
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.bounds.width / 2.0
        userPhotoImageView.clipsToBounds = true
        
        if let poster = post.poster {
            userNameLabel.text = poster.name
            storageReference.child(poster.photo).downloadURL { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.userPhotoImageView.sd_setImage(with: url, completed: nil)
                }
            }
            
//            storageReference.child(poster.photo).getData(maxSize: 10 * 1024 * 1024) { (data, error) in
//                if let error = error {
//                    print(error.localizedDescription)
//                } else {
//                    self.userPhotoImageView.image = UIImage.init(data: data!)
//                }
//            }
            
            if Auth.auth().currentUser!.uid == poster.id {
                reportContainerViw.isHidden = true
                deleteContainerView.isHidden = false
            } else {
                reportContainerViw.isHidden = false
                deleteContainerView.isHidden = true
            }
        }
        
        titleLabel.text = post.title
        descriptionTextView.text = post.description
        postDateLabel.text = GlobalFunction.sharedManager.getLocalTimeStampFromUTC(post.post_date)
        likeLabel.text = "\(post.like_count)"
        commentLabel.text = "\(post.comment_count)"
        
        descriptionTextView.textColor = UIColor.black
        titleLabel.textColor = UIColor.black
        
        if post.report_count >= 3 {
            descriptionTextView.text = "This post has been flagged due to inappropriate content."
            titleLabel.text = "Inappropriate content"
            descriptionTextView.textColor = UIColor.gray
            titleLabel.textColor = UIColor.gray
            
            descriptionTextView.frame.size.height = 60
            toolbarView.isHidden = true
            thumbImageView.isHidden = true
        } else {
            toolbarView.isHidden = false
            thumbImageView.isHidden = false
            descriptionTextView.sizeToFit()
            descriptionTextView.frame.size.width = self.bounds.width - 20
            
            if post.image != "" {
                storageReference.child(post.image).downloadURL { (url, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.thumbImageView.sd_setImage(with: url, completed: nil)
                    }
                }
                
                //            storageReference.child(post.image).getData(maxSize: 10 * 1024 * 1024) { (data, error) in
                //                if let error = error {
                //                    print(error.localizedDescription)
                //                } else {
                //                    self.thumbImageView.image = UIImage.init(data: data!)
                //                }
                //            }
            }
        }
        
        likeImageView.image = UIImage.init(named: "Image_like_black")
        databaseReference.child("likes").child(post.class_id).child(post.id!).observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                guard let child_snapshot = child as? DataSnapshot else {
                    continue
                }
                
                if let like = Like.init(snapshot: child_snapshot) {
                    if Auth.auth().currentUser?.uid == like.like_user?.id {
                        self.likeImageView.image = UIImage.init(named: "Image_liked_black")
                        self.likeKey = child_snapshot.key
                        break
                    }
                }
            }
        }
        
        bookmarkImageView.image = UIImage.init(named: "Image_bookmark_black")
        databaseReference.child("bookmarks").child(post.class_id).child(post.id!).observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                guard let child_snapshot = child as? DataSnapshot else {
                    continue
                }
                
                if let bookmark = child_snapshot.value as? [String : String] {
                    if Auth.auth().currentUser?.uid == bookmark["bookmark_user_id"] {
                        self.bookmarkImageView.image = UIImage.init(named: "Image_bookmarked_black")
                        self.bookmarkKey = child_snapshot.key
                        break
                    }
                }
            }
        }
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        if likeKey != "" {
            self.databaseReference.child("likes").child(post!.class_id).child(post!.id!).child(likeKey).removeValue { (error, ref) in
                if error != nil {
                    
                } else {
                    self.databaseReference.child("posts").child(self.post!.class_id).child(self.post!.id!).child("like_count").observeSingleEvent(of: .value, with: { (snapshot) in
                        var like_count = snapshot.value as? Int ?? 0
                        like_count = like_count - 1
                        like_count = like_count > -1 ? like_count : 0
                        
                        self.databaseReference.child("posts").child(self.post!.class_id).child(self.post!.id!).child("like_count").setValue(like_count)
                        self.databaseReference.child("user_likes").child(Auth.auth().currentUser!.uid).child(self.post!.class_id).child(self.post!.id!).setValue("")
                        self.delegate?.postCellLikeButtonClicked(self.index, like_count)
                    })
                }
            }
        } else {
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.databaseReference.child("likes").child(post!.class_id).child(post!.id!).childByAutoId().setValue(["like_date": dateFormatter.string(from: Date()), "like_user": ["id": Auth.auth().currentUser!.uid, "name": GlobalVariable.sharedManager.loggedInUser!.name, "photo": GlobalVariable.sharedManager.loggedInUser!.photo]]) { (error, ref) in
                if error != nil {
                    
                } else {
                    self.databaseReference.child("posts").child(self.post!.class_id).child(self.post!.id!).child("like_count").observeSingleEvent(of: .value, with: { (snapshot) in
                        var like_count = snapshot.value as? Int ?? 0
                        like_count = like_count + 1
                        
                        self.databaseReference.child("posts").child(self.post!.class_id).child(self.post!.id!).child("like_count").setValue(like_count)
                        self.databaseReference.child("user_likes").child(Auth.auth().currentUser!.uid).child(self.post!.class_id).child(self.post!.id!).setValue(ref.key)
                        self.delegate?.postCellLikeButtonClicked(self.index, like_count)
                    })
                }
            }
        }
    }
    
    @IBAction func commentButtonClicked(_ sender: Any) {
        delegate?.postCellCommentButtonClicked(self.post!)
    }
    
    @IBAction func bookmarkButtonClicked(_ sender: Any) {
        if bookmarkKey != "" {
            self.databaseReference.child("bookmarks").child(post!.class_id).child(post!.id!).child(bookmarkKey).removeValue { (error, ref) in
                if error != nil {
                    
                } else {
                    self.databaseReference.child("user_bookmarks").child(Auth.auth().currentUser!.uid).child(self.post!.class_id).child(self.post!.id!).setValue("")
                }
            }
        } else {
            self.databaseReference.child("bookmarks").child(post!.class_id).child(post!.id!).childByAutoId().setValue(["bookmark_user_id": Auth.auth().currentUser!.uid]) { (error, ref) in
                if error != nil {
                    
                } else {
                    self.databaseReference.child("user_bookmarks").child(Auth.auth().currentUser!.uid).child(self.post!.class_id).child(self.post!.id!).setValue(ref.key)
                }
            }
        }
        delegate?.postCellBookmarkButtonClicked(self.post!)
    }
    
    @IBAction func reportButtonClicked(_ sender: Any) {
        delegate?.postCellReportButtonClicked(self.post!)
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        delegate?.postCellDeleteButtonClicked(self.post!)
    }
    
}
