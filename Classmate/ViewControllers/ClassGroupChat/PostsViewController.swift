//
//  PostsViewController.swift
//  Classmate
//
//  Created by Administrator on 7/12/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class PostsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PostTextTableViewCellDelegate, PostImageTableViewCellDelegate, PostVideoTableViewCellDelegate, CreatePostViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var categories: [String] = ["All", "Homework", "Project", "Exam", "Bookmark", "Other"]
    var posts = [Post]()
    var selectedClass: Class?
    var selectedCategory = "All"
    
    let databaseReference = Database.database().reference()
    let storageReference = Storage.storage().reference()
    
    let refreshControl = UIRefreshControl()
    
    var bookmarkHandle: UInt = 0
    var likeHandle: UInt = 1
    var postHandle: UInt = 2
    var readHandle: UInt = 3
    
    var liked: [String : String] = [:]
    var bookmarked: [String : String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        tableView.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - postButton.frame.origin.y))
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        tableView.register(UINib.init(nibName: "PostTextTableViewCell", bundle: nil), forCellReuseIdentifier: "PostTextTableViewCell")
        tableView.register(UINib.init(nibName: "PostImageTableViewCell", bundle: nil), forCellReuseIdentifier: "PostImageTableViewCell")
        tableView.register(UINib.init(nibName: "PostVideoTableViewCell", bundle: nil), forCellReuseIdentifier: "PostVideoTableViewCell")
        
        postButton.layer.cornerRadius = postButton.bounds.width / 2.0
        postButton.clipsToBounds = true
        
        titleLabel.text = selectedClass!.title
        
        loadPosts()
        setupObservers()
    }
    
    func setupObservers() {
        postHandle = databaseReference.child("posts").child(selectedClass!.id).observe(.childChanged) { (snapshot) in
            if let updated_post = Post.init(snapshot: snapshot) {
                for i in 0..<self.posts.count {
                    let post = self.posts[i]
                    if post.id == updated_post.id {
                        if updated_post.deleted == 1 {
                            self.posts.remove(at: i)
                        } else {
                            self.posts[i] = updated_post
                        }
                        break
                    }
                }
                self.tableView.reloadData()
            }
        }
        likeHandle = databaseReference.child("user_likes").child(Auth.auth().currentUser!.uid).child(selectedClass!.id).observe(.value, with: { (snapshot) in
            self.liked.removeAll()
            for child in snapshot.children {
                guard let child_snapshot = child as? DataSnapshot else {
                    break
                }
                
                guard let liked_key = child_snapshot.value as? String else {
                    break
                }
                
                if liked_key != "" {
                    self.liked[child_snapshot.key] = liked_key
                }
            }
            self.tableView.reloadData()
        })
        bookmarkHandle = databaseReference.child("user_bookmarks").child(Auth.auth().currentUser!.uid).child(selectedClass!.id).observe(.value, with: { (snapshot) in
            self.bookmarked.removeAll()
            for child in snapshot.children {
                guard let child_snapshot = child as? DataSnapshot else {
                    break
                }
                
                guard let bookmarked_key = child_snapshot.value as? String else {
                    break
                }
                
                if bookmarked_key != "" {
                    self.bookmarked[child_snapshot.key] = bookmarked_key
                }
            }
            self.tableView.reloadData()
        })
        
        databaseReference.child("reads").child(Auth.auth().currentUser!.uid).observe(.value) { (snapshot) in
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func removeObservers() {
        databaseReference.child("user_likes").child(Auth.auth().currentUser!.uid).child(selectedClass!.id).removeObserver(withHandle: likeHandle)
        databaseReference.child("user_bookmarks").child(Auth.auth().currentUser!.uid).child(selectedClass!.id).removeObserver(withHandle: bookmarkHandle)
        databaseReference.child("posts").child(selectedClass!.id).removeObserver(withHandle: postHandle)
        databaseReference.child("reads").child(Auth.auth().currentUser!.uid).removeObserver(withHandle: readHandle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPostViewControllerDidPosted() {
        loadPosts()
    }
    
    func getLabelHeight(_ text: String) -> CGFloat {
        let label = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: CGFloat.greatestFiniteMagnitude))
//        label.numberOfLines = 0
//        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.font = UIFont.init(name: "Avenir-Light", size: 14)
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadPosts() {
        databaseReference.child("posts").child(selectedClass!.id).observeSingleEvent(of: .value) { (snapshot) in
            self.posts.removeAll()
            var last_post_id = -1
            for child in snapshot.children {
                guard let child_snapshot = child as? DataSnapshot else {
                    continue
                }
                if let post = Post.init(snapshot: child_snapshot) {
                    if self.selectedCategory == "Bookmark" {
                        if self.bookmarked.keys.contains(post.id!) {
                            self.posts.append(post)
                        }
                    } else {
                        if (post.category == self.selectedCategory || self.selectedCategory == "All") && post.deleted == 0 {
                            self.posts.append(post)
                        }
                    }
                    
                    if last_post_id < Int(post.id ?? "-1")! {
                        last_post_id = Int(post.id ?? "-1")!
                    }
                }
            }            
            self.posts.sort(by: {$0.post_date > $1.post_date})
            
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
            
            if last_post_id > -1 && last_post_id > Int(GlobalVariable.sharedManager.reads[self.selectedClass!.id] ?? "-1")! {
                GlobalVariable.sharedManager.reads[self.selectedClass!.id] = "\(last_post_id)"
                self.databaseReference.child("reads").child(Auth.auth().currentUser!.uid).setValue(GlobalVariable.sharedManager.reads)
            }
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        self.loadPosts()
    }
    
    @IBAction func categoryButtonClicked(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: "Choose a category", preferredStyle: .actionSheet)
        for i in 0..<categories.count {
            let categoryAction = UIAlertAction(title: categories[i], style: .default, handler: { (action) -> Void in
                self.categoryButton.setTitle("• \(self.categories[i])", for: .normal)
                self.selectedCategory = self.categories[i]
                self.loadPosts()
            })
            alertController.addAction(categoryAction)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        })
        alertController.addAction(cancelButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        removeObservers()
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if posts[indexPath.row].report_count >= 3 {
            return 140
        } else {
            if posts[indexPath.row].video != "" {
                return 80.0 + getLabelHeight(posts[indexPath.row].description) + 410.0
            } else if posts[indexPath.row].image != "" {
                return 80.0 + getLabelHeight(posts[indexPath.row].description) + 410.0
            } else {
                return 80.0 + getLabelHeight(posts[indexPath.row].description) + 55.0
            }
        }        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if posts[indexPath.row].video != "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostVideoTableViewCell", for: indexPath) as! PostVideoTableViewCell
            cell.initCell(posts[indexPath.row], index: indexPath.row)
            cell.delegate = self
            cell.likeKey = ""
            cell.bookmarkKey = ""
            
            cell.likeImageView.image = UIImage.init(named: "Image_like_black")
            for key in liked.keys {
                if key == posts[indexPath.row].id! {
                    cell.likeImageView.image = UIImage.init(named: "Image_liked_black")
                    cell.likeKey = liked[key]!
                    break
                }
            }
            
            cell.bookmarkImageView.image = UIImage.init(named: "Image_bookmark_black")
            for key in bookmarked.keys {
                if key == posts[indexPath.row].id! {
                    cell.bookmarkImageView.image = UIImage.init(named: "Image_bookmarked_black")
                    cell.bookmarkKey = bookmarked[key]!
                    break
                }
            }
            
            return cell
        } else if posts[indexPath.row].image != "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostImageTableViewCell", for: indexPath) as! PostImageTableViewCell
            cell.initCell(posts[indexPath.row], index: indexPath.row)
            cell.delegate = self
            cell.likeKey = ""
            cell.bookmarkKey = ""
            
            cell.likeImageView.image = UIImage.init(named: "Image_like_black")
            for key in liked.keys {
                if key == posts[indexPath.row].id! {
                    cell.likeImageView.image = UIImage.init(named: "Image_liked_black")
                    cell.likeKey = liked[key]!
                    break
                }
            }
            
            cell.bookmarkImageView.image = UIImage.init(named: "Image_bookmark_black")
            for key in bookmarked.keys {
                if key == posts[indexPath.row].id! {
                    cell.bookmarkImageView.image = UIImage.init(named: "Image_bookmarked_black")
                    cell.bookmarkKey = bookmarked[key]!
                    break
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTextTableViewCell", for: indexPath) as! PostTextTableViewCell
            cell.initCell(posts[indexPath.row], index: indexPath.row)
            cell.delegate = self
            cell.likeKey = ""
            cell.bookmarkKey = ""
            
            cell.likeImageView.image = UIImage.init(named: "Image_like_black")
            for key in liked.keys {
                if key == posts[indexPath.row].id! {
                    cell.likeImageView.image = UIImage.init(named: "Image_liked_black")
                    cell.likeKey = liked[key]!
                    break
                }
            }
            
            cell.bookmarkImageView.image = UIImage.init(named: "Image_bookmark_black")
            for key in bookmarked.keys {
                if key == posts[indexPath.row].id! {
                    cell.bookmarkImageView.image = UIImage.init(named: "Image_bookmarked_black")
                    cell.bookmarkKey = bookmarked[key]!
                    break
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if posts[indexPath.row].report_count >= 3 {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        viewController.post = posts[indexPath.row]
        viewController.selectedClass = selectedClass
        
        var bookmark_key = ""
        for key in bookmarked.keys {
            if key == posts[indexPath.row].id! {
                bookmark_key = bookmarked[key]!
                break
            }
        }
        viewController.bookmarkKey = bookmark_key
        
        var like_key = ""
        for key in liked.keys {
            if key == posts[indexPath.row].id! {
                like_key = liked[key]!
                break
            }
        }
        viewController.likeKey = like_key
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func membersButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MembersViewController") as! MembersViewController
        viewController.members = self.selectedClass!.members
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func postButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CreatePostViewController") as! CreatePostViewController
        viewController.selectedClass = selectedClass
        viewController.delegate = self
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    func postCellLikeButtonClicked(_ index: Int, _ like_count: Int) {
        posts[index].setLikeCount(like_count)
    }
    
    func postCellCommentButtonClicked(_ post: Post) {
        if post.report_count >= 3 {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        viewController.post = post
        viewController.selectedClass = selectedClass
        
        var bookmark_key = ""
        for key in bookmarked.keys {
            if key == post.id! {
                bookmark_key = bookmarked[key]!
                break
            }
        }
        viewController.bookmarkKey = bookmark_key
        
        var like_key = ""
        for key in liked.keys {
            if key == post.id! {
                like_key = liked[key]!
                break
            }
        }
        viewController.likeKey = like_key
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func postCellBookmarkButtonClicked(_ post: Post) {
        
    }
    
    func postCellReportButtonClicked(_ post: Post) {
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let okAction = UIAlertAction.init(title: "It's inappropriate", style: .destructive) { (action) in
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let now = dateFormatter.string(from: Date())
            self.databaseReference.child("post_reports").child(post.class_id).child(post.id!).observeSingleEvent(of: .value, with: { (snapshot) in
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
                    self.databaseReference.child("post_reports").child(post.class_id).child(post.id!).childByAutoId().setValue(["report_date": now, "report_description": "inappropriate", "report_user_id": Auth.auth().currentUser!.uid])
                    
                    self.databaseReference.child("posts").child(post.class_id).child(post.id!).child("report_count").observeSingleEvent(of: .value, with: { (snapshot) in
                        var report_count = 1
                        if let count = snapshot.value as? Int {
                            report_count = count + 1
                        }
                        self.databaseReference.child("posts").child(post.class_id).child(post.id!).child("report_count").setValue(report_count)
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
    
    func postCellDeleteButtonClicked(_ post: Post) {
        let alertController = UIAlertController.init(title: nil, message: "Are you sure you want to delete this post?", preferredStyle: .actionSheet)
        let okAction = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
            self.databaseReference.child("posts").child(post.class_id).child(post.id!).child("deleted").setValue(1, withCompletionBlock: { (error, ref) in
                if error == nil {
                    if let last_post = self.selectedClass!.last_post {
                        if post.id! >= last_post.id! {
                            self.updateLatestPost(cur_post: post)
                        }
                    }
                }
            })
        }
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction.init(title: "No", style: .cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateLatestPost(cur_post: Post) {
        self.databaseReference.child("classes").child(cur_post.class_id).child("last_post").child("id").observeSingleEvent(of: .value) { (snapshot) in
            if let id = snapshot.value as? String {
                if id == cur_post.id! {
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
                            self.databaseReference.child("classes").child(cur_post.class_id).child("last_post").removeValue()
                        } else {
                            self.databaseReference.child("classes").child(cur_post.class_id).child("last_post").setValue(new_latest_post?.toAnyObject())
                        }
                    }
                }
            }
        }
    }
    
    func postCellPlayButtonClicked(_ post: Post) {
        if post.video != "" {
            storageReference.child(post.video).downloadURL { (url, error) in
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
    
}

