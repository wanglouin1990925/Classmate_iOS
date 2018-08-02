//
//  CommentTableViewCell.swift
//  Classmate
//
//  Created by Administrator on 7/16/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

protocol CommentTableViewCellDelegate: NSObjectProtocol {
    func commentCellReportButtonClicked(_ comment: Comment)
    func commentCellDeleteButtonClicked(_ comment: Comment)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    
    @IBOutlet weak var reportContainerView: UIView!
    @IBOutlet weak var deleteContainerView: UIView!
    
    let databaseReference = Database.database().reference()
    let storageReference = Storage.storage().reference()
    
    var isLiked = false
    var comment: Comment?
    
    var delegate: CommentTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCell(_ comment: Comment) {
        self.comment = comment
        
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.bounds.width / 2.0
        userPhotoImageView.clipsToBounds = true
        
        if let comment_user = comment.comment_user {
            userNameLabel.text = comment_user.name
            storageReference.child(comment_user.photo).downloadURL { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.userPhotoImageView.sd_setImage(with: url, completed: nil)
                }
            }
            
//            storageReference.child(comment_user.photo).getData(maxSize: 10 * 1024 * 1024) { (data, error) in
//                if let error = error {
//                    print(error.localizedDescription)
//                } else {
//                    self.userPhotoImageView.image = UIImage.init(data: data!)
//                }
//            }
            
        }
        
        descriptionTextView.text = comment.comment_description
        postDateLabel.text = GlobalFunction.sharedManager.getLocalTimeStampFromUTC(comment.comment_date)
        likeLabel.text = "\(comment.comment_like_count)"
        
        if Auth.auth().currentUser!.uid == comment.comment_user!.id {
            deleteContainerView.isHidden = false
            reportContainerView.isHidden = true
        } else {
            deleteContainerView.isHidden = true
            reportContainerView.isHidden = false
        }
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        if isLiked != false {
            self.databaseReference.child("comments").child(comment!.class_id).child(comment!.post_id).child(comment!.id).child("comment_like_count").observeSingleEvent(of: .value, with: { (snapshot) in
                var comment_like_count = snapshot.value as? Int ?? 0
                comment_like_count = comment_like_count - 1
                comment_like_count = comment_like_count > -1 ? comment_like_count : 0
                
                self.databaseReference.child("comments").child(self.comment!.class_id).child(self.comment!.post_id).child(self.comment!.id).child("comment_like_count").setValue(comment_like_count)
                self.databaseReference.child("comment_likes").child(Auth.auth().currentUser!.uid).child(self.comment!.class_id).child(self.comment!.post_id).child(self.comment!.id).setValue("0")
            })
        } else {
            self.databaseReference.child("comments").child(comment!.class_id).child(comment!.post_id).child(comment!.id).child("comment_like_count").observeSingleEvent(of: .value, with: { (snapshot) in
                var comment_like_count = snapshot.value as? Int ?? 0
                comment_like_count = comment_like_count + 1

                self.databaseReference.child("comments").child(self.comment!.class_id).child(self.comment!.post_id).child(self.comment!.id).child("comment_like_count").setValue(comment_like_count)
                self.databaseReference.child("comment_likes").child(Auth.auth().currentUser!.uid).child(self.comment!.class_id).child(self.comment!.post_id).child(self.comment!.id).setValue("1")
            })
        }
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        delegate?.commentCellDeleteButtonClicked(comment!)
    }
    
    @IBAction func reportButtonClicked(_ sender: Any) {
        delegate?.commentCellReportButtonClicked(comment!)
    }
    
}
