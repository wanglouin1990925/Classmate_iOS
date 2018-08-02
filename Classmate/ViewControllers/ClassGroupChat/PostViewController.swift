//
//  SinglePostViewController.swift
//  Classmate
//
//  Created by Administrator on 7/12/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import NextGrowingTextView
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class PostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CommentTableViewCellDelegate {

    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var bookmarkImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var thumbContainerView: UIView!
    @IBOutlet weak var reportContainerViw: UIView!
    @IBOutlet weak var deleteContainerView: UIView!
    
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var growingTextView: NextGrowingTextView!
    @IBOutlet weak var inputContainerViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var navTitleLabel: UILabel!
    
    let databaseReference = Database.database().reference()
    let storageReference = Storage.storage().reference()
    
    var post: Post?
    var comments: [Comment] = [Comment]()
    
    var bookmarkKey = ""
    var likeKey = ""
    
    var postHandle: UInt = 0
    var commentHandle: UInt = 1
    var commentLikeHandle: UInt = 2
    
    var commentLiked: [String : String] = [:]
    var selectedClass: Class?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        self.sendButton.layer.cornerRadius = 15
        self.sendButton.clipsToBounds = true
        
        self.playButton.layer.cornerRadius = self.playButton.bounds.width / 2.0
        self.playButton.clipsToBounds = true
        
        self.growingTextView.textView.font = UIFont.init(name: "Avenir-Book", size: 14)
        self.growingTextView.layer.cornerRadius = 15
        self.growingTextView.textView.textContainerInset = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 4)
        self.growingTextView.placeholderAttributedText = NSAttributedString(string: "Add a comment",
                                                                            attributes: [NSAttributedStringKey.font: self.growingTextView.textView.font!,
                                                                                         NSAttributedStringKey.foregroundColor: UIColor.gray
            ]
        )
        self.growingTextView.delegates.didChangeHeight = { [weak self] height in
            guard let weakself = self else { return }
            weakself.scrollToLastRow()
        }
        
        tableView.register(UINib.init(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        tableView.tableFooterView = UIView.init()

        showData()
        setupObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollToLastRow() {
        if comments.count > 0 {
            let indexPath = IndexPath.init(row: comments.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        } else {
            if self.tableView.contentSize.height - self.tableView.frame.size.height > 0 {
                let scrollPoint = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height)
                self.tableView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }

    func getLabelHeight(_ text: String, fontsize: Int) -> CGFloat {
        let label = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: CGFloat.greatestFiniteMagnitude))
//        label.numberOfLines = 0
//        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.font = UIFont.init(name: "Avenir-Light", size: CGFloat(fontsize))
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    func showData() {
        if post!.video != "" {
            playButton.isHidden = false
            thumbContainerView.isHidden = false
            headerView.frame.size.height = 80.0 + getLabelHeight(post!.description, fontsize: 14) + 410.0
            
            if post!.image != "" {
                storageReference.child(post!.image).downloadURL { (url, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.thumbImageView.sd_setImage(with: url, completed: nil)
                    }
                }
                
//                storageReference.child(post!.image).getData(maxSize: 10 * 1024 * 1024) { (data, error) in
//                    if let error = error {
//                        print(error.localizedDescription)
//                    } else {
//                        self.thumbImageView.image = UIImage.init(data: data!)
//                    }
//                }
            }
        } else if post!.image != "" {
            playButton.isHidden = true
            thumbContainerView.isHidden = false
            headerView.frame.size.height = 80.0 + getLabelHeight(post!.description, fontsize: 14) + 410.0
            
            storageReference.child(post!.image).downloadURL { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.thumbImageView.sd_setImage(with: url, completed: nil)
                }
            }
            
//            storageReference.child(post!.image).getData(maxSize: 10 * 1024 * 1024) { (data, error) in
//                if let error = error {
//                    print(error.localizedDescription)
//                } else {
//                    self.thumbImageView.image = UIImage.init(data: data!)
//                }
//            }
        } else {
            playButton.isHidden = true
            thumbContainerView.isHidden = true
            headerView.frame.size.height = 80.0 + getLabelHeight(post!.description, fontsize: 14) + 55.0
            descriptionTextView.frame.size.height = headerView.frame.size.height - 130
        }
        
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.bounds.width / 2.0
        userPhotoImageView.clipsToBounds = true
        
        playButton.layer.cornerRadius = playButton.bounds.width / 2.0
        playButton.clipsToBounds = true
        
        if let poster = post!.poster {
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
        
        titleLabel.text = post!.title
        descriptionTextView.text = post!.description
        postDateLabel.text = GlobalFunction.sharedManager.getLocalTimeStampFromUTC(post!.post_date)
        likeLabel.text = "\(post!.like_count)"
        commentLabel.text = "\(post!.comment_count)"
        
        descriptionTextView.textColor = UIColor.black
        titleLabel.textColor = UIColor.black
        
        if post!.report_count >= 3 {
            descriptionTextView.text = "This post has been flagged due to inappropriate content."
            titleLabel.text = "Inappropriate content"
            descriptionTextView.textColor = UIColor.gray
            titleLabel.textColor = UIColor.gray
        }
        
        likeImageView.image = UIImage.init(named: "Image_like_black")
        if likeKey != "" {
            likeImageView.image = UIImage.init(named: "Image_liked_black")
        }
        
        bookmarkImageView.image = UIImage.init(named: "Image_bookmark_black")
        if bookmarkKey != "" {
            bookmarkImageView.image = UIImage.init(named: "Image_bookmarked_black")
        }
    }
    
    func setupObservers() {
        commentLikeHandle = databaseReference.child("comment_likes").child(Auth.auth().currentUser!.uid).child(post!.class_id).child(post!.id!).observe(.value, with: { (snapshot) in
            self.commentLiked.removeAll()
            for child in snapshot.children {
                guard let child_snapshot = child as? DataSnapshot else {
                    break
                }
                
                guard let is_liked = child_snapshot.value as? String else {
                    break
                }
                
                if is_liked != "0" {
                    self.commentLiked[child_snapshot.key] = is_liked
                }
            }
            self.tableView.reloadData()
        })
        
        postHandle = databaseReference.child("posts").child(post!.class_id).child(post!.id!).observe(.value, with: { (snapshot) in
            if let post = Post.init(snapshot: snapshot) {
                self.post = post
                self.showData()
            }
        })
        
        commentHandle = databaseReference.child("comments").child(post!.class_id).child(post!.id!).observe(.value, with: { (snapshot) in
            self.comments.removeAll()
            for child in snapshot.children {
                guard let child_snapshot = child as? DataSnapshot else {
                    continue
                }
                if let comment = Comment.init(snapshot: child_snapshot) {
                    self.comments.append(comment)
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func removeObservers() {
        databaseReference.child("posts").child(post!.class_id).child(post!.id!).removeObserver(withHandle: postHandle)
        databaseReference.child("comments").child(post!.class_id).child(post!.id!).removeObserver(withHandle: commentHandle)
        databaseReference.child("comment_likes").child(Auth.auth().currentUser!.uid).child(post!.class_id).child(post!.id!).removeObserver(withHandle: commentLikeHandle)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        cell.initCell(comments[indexPath.row])
        cell.delegate = self
        
        cell.isLiked = false
        cell.likeImageView.image = UIImage.init(named: "Image_like_black")
        
        if commentLiked.keys.contains(comments[indexPath.row].id) {
            if commentLiked[comments[indexPath.row].id] == "1" {
                cell.isLiked = true
                cell.likeImageView.image = UIImage.init(named: "Image_liked_black")
            }
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0 + getLabelHeight(comments[indexPath.row].comment_description, fontsize: 12) + 35.0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func handleSendButton(_ sender: AnyObject) {
        if self.growingTextView.textView.text == "" {
            return
        }
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let comment_description = self.growingTextView.textView.text
        let comment_date = dateFormatter.string(from: Date())
        let comment_user = Poster.init(Auth.auth().currentUser!.uid, GlobalVariable.sharedManager.loggedInUser!.name, GlobalVariable.sharedManager.loggedInUser!.photo)
        let comment_like_count = 0
        let comment_report_count = 0
        
        let comment = Comment.init(comment_user: comment_user, comment_description: comment_description!, comment_date: comment_date, comment_like_count: comment_like_count, comment_report_count: comment_report_count, class_id: post!.class_id, post_id: post!.id!)
        
        self.databaseReference.child("comments").child(post!.class_id).child(post!.id!).childByAutoId().setValue(comment.toAnyObject()) { (error, ref) in
            if error == nil {
                self.scrollToLastRow()
                self.growingTextView.textView.text = ""
                
                self.databaseReference.child("posts").child(self.post!.class_id).child(self.post!.id!).child("comment_count").observeSingleEvent(of: .value, with: { (snapshot) in
                    var comment_count = snapshot.value as? Int ?? 0
                    comment_count = comment_count + 1
                    self.databaseReference.child("posts").child(self.post!.class_id).child(self.post!.id!).child("comment_count").setValue(comment_count)
                })
            }
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let _ = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                self.inputContainerViewBottom.constant =  0
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                    self.scrollToLastRow()
                }
            }
        }
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                self.inputContainerViewBottom.constant = keyboardHeight
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                    self.scrollToLastRow()
                }
            }
        }
    }
    
    @IBAction func playButtonClicked(_ sender: Any) {
        if post!.video != "" {
//            let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
//            let player = AVPlayer(url: videoURL!)
//            let playerViewController = AVPlayerViewController()
//            playerViewController.player = player
//            self.present(playerViewController, animated: true) {
//                playerViewController.player!.play()
//            }
            
            storageReference.child(post!.video).downloadURL { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    let videoURL = url
                    let player = AVPlayer(url: videoURL!)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
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
                    self.likeImageView.image = UIImage.init(named: "Image_like_black")
                    self.likeKey = ""

                    self.databaseReference.child("posts").child(self.post!.class_id).child(self.post!.id!).child("like_count").observeSingleEvent(of: .value, with: { (snapshot) in
                        var like_count = snapshot.value as? Int ?? 0
                        like_count = like_count - 1
                        like_count = like_count > -1 ? like_count : 0
                        self.databaseReference.child("posts").child(self.post!.class_id).child(self.post!.id!).child("like_count").setValue(like_count)
                        self.databaseReference.child("user_likes").child(Auth.auth().currentUser!.uid).child(self.post!.class_id).child(self.post!.id!).setValue("")
                    })
                }
            }
        } else {
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.databaseReference.child("likes").child(post!.class_id).child(post!.id!).childByAutoId().setValue(["like_date": dateFormatter.string(from: Date()), "like_user": ["id": Auth.auth().currentUser!.uid, "name": GlobalVariable.sharedManager.loggedInUser!.name, "photo": GlobalVariable.sharedManager.loggedInUser!.photo]]) { (error, ref) in
                if error != nil {
                    
                } else {
                    self.likeImageView.image = UIImage.init(named: "Image_liked_black")
                    self.likeKey = ref.key
                    
                    self.databaseReference.child("posts").child(self.post!.class_id).child(self.post!.id!).child("like_count").observeSingleEvent(of: .value, with: { (snapshot) in
                        var like_count = snapshot.value as? Int ?? 0
                        like_count = like_count + 1
                        self.databaseReference.child("posts").child(self.post!.class_id).child(self.post!.id!).child("like_count").setValue(like_count)
                        self.databaseReference.child("user_likes").child(Auth.auth().currentUser!.uid).child(self.post!.class_id).child(self.post!.id!).setValue(ref.key)
                    })
                }
            }
        }
    }
    
    @IBAction func commentButtonClicked(_ sender: Any) {

    }
    
    @IBAction func bookmarkButtonClicked(_ sender: Any) {
        if bookmarkKey != "" {
            self.databaseReference.child("bookmarks").child(post!.class_id).child(post!.id!).child(bookmarkKey).removeValue { (error, ref) in
                if error != nil {
                    
                } else {
                    self.bookmarkImageView.image = UIImage.init(named: "Image_bookmark_black")
                    self.bookmarkKey = ""
                    
                    self.databaseReference.child("user_bookmarks").child(Auth.auth().currentUser!.uid).child(self.post!.class_id).child(self.post!.id!).setValue("")
                }
            }
        } else {
            self.databaseReference.child("bookmarks").child(post!.class_id).child(post!.id!).childByAutoId().setValue(["bookmark_user_id": Auth.auth().currentUser!.uid]) { (error, ref) in
                if error != nil {
                    
                } else {
                    self.bookmarkImageView.image = UIImage.init(named: "Image_bookmarked_black")
                    self.bookmarkKey = ref.key
                    
                    self.databaseReference.child("user_bookmarks").child(Auth.auth().currentUser!.uid).child(self.post!.class_id).child(self.post!.id!).setValue(ref.key)
                }
            }
        }
    }
    
    @IBAction func reportButtonClicked(_ sender: Any) {
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let okAction = UIAlertAction.init(title: "It's inappropriate", style: .destructive) { (action) in
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let now = dateFormatter.string(from: Date())
            self.databaseReference.child("post_reports").child(self.post!.class_id).child(self.post!.id!).observeSingleEvent(of: .value, with: { (snapshot) in
                var isReported = false
                for child in snapshot.children {
                    if let child_snapshot = child as? DataSnapshot {
                        if let report_user_id = child_snapshot.childSnapshot(forPath: "report_user_id").value as? String {
                            if report_user_id == Auth.auth().currentUser!.uid {
                                isReported = true
                                break
                            }
                        }
                    }
                }
                
                if isReported == false {
                    self.databaseReference.child("post_reports").child(self.post!.class_id).child(self.post!.id!).childByAutoId().setValue(["report_date": now, "report_description": "inappropriate", "report_user_id": Auth.auth().currentUser!.uid])
                    self.databaseReference.child("posts").child(self.post!.class_id).child(self.post!.id!).child("report_count").observeSingleEvent(of: .value, with: { (snapshot) in
                        var report_count = 1
                        if let count = snapshot.value as? Int {
                            report_count = count + 1
                        }
                        self.databaseReference.child("posts").child(self.post!.class_id).child(self.post!.id!).child("report_count").setValue(report_count)
                    })
                }
            })
            
        }
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        let alertController = UIAlertController.init(title: nil, message: "Are you sure you want to delete this post?", preferredStyle: .actionSheet)
        let okAction = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
            self.databaseReference.child("posts").child(self.post!.class_id).child(self.post!.id!).child("deleted").setValue(1, withCompletionBlock: { (error, ref) in
                if error == nil {
                    if let last_post = self.selectedClass!.last_post {
                        if self.post!.id! >= last_post.id! {
                            self.updateLatestPost()
                        }
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction.init(title: "No", style: .cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateLatestPost() {
        self.databaseReference.child("classes").child(selectedClass!.id).child("last_post").child("id").observeSingleEvent(of: .value) { (snapshot) in
            if let id = snapshot.value as? String {
                if id == self.post!.id! {
                    self.databaseReference.child("posts").child(self.selectedClass!.id).queryLimited(toLast: 20).observeSingleEvent(of: .value) { (snapshot) in
                        var recent_posts = [Post]()
                        for child in snapshot.children {
                            guard let child_snapshot = child as? DataSnapshot else {
                                continue
                            }
                            if let recent_post = Post.init(snapshot: child_snapshot) {
                                recent_posts.append(recent_post)
                            }
                        }
                        recent_posts.sort(by: {$0.post_date > $1.post_date})
                        
                        var new_latest_post: Post?
                        for recent_post in recent_posts {
                            if recent_post.deleted == 0 {
                                new_latest_post = recent_post
                                break
                            }
                        }
                        
                        if new_latest_post == nil {
                            self.databaseReference.child("classes").child(self.post!.class_id).child("last_post").removeValue()
                        } else {
                            self.databaseReference.child("classes").child(self.post!.class_id).child("last_post").setValue(new_latest_post?.toAnyObject())
                        }
                    }
                }
            }
        }
    }
    
    func commentCellDeleteButtonClicked(_ comment: Comment) {
        let alertController = UIAlertController.init(title: nil, message: "Are you sure you want to delete this comment?", preferredStyle: .actionSheet)
        let okAction = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
            self.databaseReference.child("comments").child(comment.class_id).child(comment.post_id).child(comment.id).removeValue()

            self.databaseReference.child("posts").child(self.post!.class_id).child(self.post!.id!).child("comment_count").observeSingleEvent(of: .value, with: { (snapshot) in
                var comment_count = snapshot.value as? Int ?? 0
                comment_count = comment_count - 1
                comment_count = comment_count > -1 ? comment_count : 0
                self.databaseReference.child("posts").child(self.post!.class_id).child(self.post!.id!).child("comment_count").setValue(comment_count)
            })
        }
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction.init(title: "No", style: .cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func commentCellReportButtonClicked(_ comment: Comment) {
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let okAction = UIAlertAction.init(title: "It's inappropriate", style: .destructive) { (action) in
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let now = dateFormatter.string(from: Date())
            self.databaseReference.child("comment_reports").child(comment.class_id).child(comment.post_id).child(comment.id).childByAutoId().setValue(["report_date": now, "report_description": "inappropriate", "report_user_id": Auth.auth().currentUser!.uid])
        }
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
