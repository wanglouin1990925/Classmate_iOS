//
//  GroupChatViewController.swift
//  Classmate
//
//  Created by Administrator on 7/12/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class GroupChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!    
    @IBOutlet weak var topbarView: UIView!
    
    let refreshControl = UIRefreshControl()
    
    let databaseReference = Database.database().reference()
    let storageReference = Storage.storage().reference()
    
    var classes = [Class]()
    var classHandle: UInt = 0
    var readHandle: UInt = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        tableView.tableFooterView = UIView.init()
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupObservers()
        self.loadClasses()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObservers()
    }
    
    func setupObservers() {
        classHandle = databaseReference.child("classes").observe(.childChanged, with: { (snapshot) in
            if let updated_group = Class.init(snapshot: snapshot) {
                for i in 0..<self.classes.count {
                    let group = self.classes[i]
                    if group.id == updated_group.id {
                        self.classes[i] = updated_group
                        break
                    }
                }
                self.tableView.reloadData()
            }
        })
        readHandle = databaseReference.child("reads").child(Auth.auth().currentUser!.uid).observe(.value, with: { (snapshot) in
            self.tableView.reloadData()
        })
    }
    
    func removeObservers() {
        databaseReference.child("classes").removeObserver(withHandle: classHandle)
        databaseReference.child("reads").child(Auth.auth().currentUser!.uid).removeObserver(withHandle: readHandle)
    }
    
    func loadClasses() {
        databaseReference.child("classes").observeSingleEvent(of: .value) { (snapshot) in
            self.classes.removeAll()
            for child in snapshot.children {
                guard let child_snapshot = child as? DataSnapshot else {
                    continue
                }
                if let group = Class.init(snapshot: child_snapshot) {
                    for member in group.members {
                        if member.id == Auth.auth().currentUser!.uid {
                            self.classes.append(group)
                        }
                    }
                }
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func refreshData(_ sender: Any) {
        loadClasses()
    }

    @IBAction func addButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AddClassViewController") as! AddClassViewController
        viewController.groupChatViewController = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let last_post = classes[indexPath.row].last_post {
            if last_post.image != "" {
                return 85
            } else {
                return 80
            }
        } else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let group = classes[indexPath.row]
        if let last_post = classes[indexPath.row].last_post {
            if last_post.video != "" && last_post.image != "" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
                
                let titleLabel = cell.viewWithTag(100) as! UILabel
                let descriptionLabel = cell.viewWithTag(101) as! UILabel
                let thumbImageView = cell.viewWithTag(102) as! UIImageView
                let badgeButton = cell.viewWithTag(103) as! MIBadgeButton
                
                var unreadCount = 0
                if let lastPost = group.last_post {
                    if let classId = GlobalVariable.sharedManager.reads[group.id] {
                        unreadCount = (Int(lastPost.id!) ?? 0) - (Int(classId) ?? 0)
                    } else {
                        unreadCount = (Int(lastPost.id!) ?? 0) + 1
                    }
                }
                if unreadCount <= 0 {
                    badgeButton.badgeString = ""
                    titleLabel.frame.size.width = self.view.frame.width - 75 - 15
                    descriptionLabel.frame.size.width = self.view.frame.width - 75 - 15
                } else {
                    badgeButton.badgeString = "\(unreadCount)"
                    titleLabel.frame.size.width = self.view.frame.width - 75 - 60
                    descriptionLabel.frame.size.width = self.view.frame.width - 75 - 60
                }
                
                titleLabel.text = group.title
                
                descriptionLabel.textColor = UIColor.black
                descriptionLabel.text = "\(last_post.title)"
                
                if last_post.report_count >= 3 {
                    descriptionLabel.textColor = UIColor.gray
                    descriptionLabel.text = "Inappropriate content"
                }
                
                storageReference.child(last_post.image).downloadURL { (url, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        thumbImageView.sd_setImage(with: url, completed: nil)
                    }
                }
                
//                storageReference.child(last_post.image).getData(maxSize: 10 * 1024 * 1024) { (data, error) in
//                    if let error = error {
//                        print(error.localizedDescription)
//                    } else {
//                        thumbImageView.image = UIImage.init(data: data!)
//                    }
//                }
                return cell
            } else if last_post.image != "" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
                
                let titleLabel = cell.viewWithTag(100) as! UILabel
                let descriptionLabel = cell.viewWithTag(101) as! UILabel
                let thumbImageView = cell.viewWithTag(102) as! UIImageView
                let badgeButton = cell.viewWithTag(103) as! MIBadgeButton
                
                var unreadCount = 0
                if let lastPost = group.last_post {
                    if let classId = GlobalVariable.sharedManager.reads[group.id] {
                        unreadCount = (Int(lastPost.id!) ?? 0) - (Int(classId) ?? 0)
                    } else {
                        unreadCount = (Int(lastPost.id!) ?? 0) + 1
                    }
                }
                if unreadCount <= 0 {
                    badgeButton.badgeString = ""
                    titleLabel.frame.size.width = self.view.frame.width - 75 - 15
                    descriptionLabel.frame.size.width = self.view.frame.width - 75 - 15
                } else {
                    badgeButton.badgeString = "\(unreadCount)"
                    titleLabel.frame.size.width = self.view.frame.width - 75 - 60
                    descriptionLabel.frame.size.width = self.view.frame.width - 75 - 60
                }
                
                titleLabel.text = group.title
                
                descriptionLabel.textColor = UIColor.black
                descriptionLabel.text = "\(last_post.title)"
                
                if last_post.report_count >= 3 {
                    descriptionLabel.textColor = UIColor.gray
                    descriptionLabel.text = "Inappropriate content"
                }
                
                storageReference.child(last_post.image).downloadURL { (url, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        thumbImageView.sd_setImage(with: url, completed: nil)
                    }
                }
                
//                storageReference.child(last_post.image).getData(maxSize: 10 * 1024 * 1024) { (data, error) in
//                    if let error = error {
//                        print(error.localizedDescription)
//                    } else {
//                        thumbImageView.image = UIImage.init(data: data!)
//                    }
//                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath)
                
                let titleLabel = cell.viewWithTag(100) as! UILabel
                let descriptionLabel = cell.viewWithTag(101) as! UILabel
                let badgeButton = cell.viewWithTag(103) as! MIBadgeButton
                
                var unreadCount = 0
                if let lastPost = group.last_post {
                    if let classId = GlobalVariable.sharedManager.reads[group.id] {
                        unreadCount = (Int(lastPost.id!) ?? 0) - (Int(classId) ?? 0)
                    } else {
                        unreadCount = (Int(lastPost.id!) ?? 0) + 1
                    }
                }
                if unreadCount <= 0 {
                    badgeButton.badgeString = ""
                    titleLabel.frame.size.width = self.view.frame.width - 15 - 15
                    descriptionLabel.frame.size.width = self.view.frame.width - 15 - 15
                } else {
                    badgeButton.badgeString = "\(unreadCount)"
                    titleLabel.frame.size.width = self.view.frame.width - 15 - 60
                    descriptionLabel.frame.size.width = self.view.frame.width - 15 - 60
                }
                
                titleLabel.text = group.title
                
                descriptionLabel.textColor = UIColor.black
                descriptionLabel.text = "\(last_post.title)"
                
                if last_post.report_count >= 3 {
                    descriptionLabel.textColor = UIColor.gray
                    descriptionLabel.text = "Inappropriate content"
                }
                
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath)
            let titleLabel = cell.viewWithTag(100) as! UILabel
            titleLabel.text = group.title
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController.init(title: nil, message: "Do you want to leave \(classes[indexPath.row].title)?", preferredStyle: .actionSheet)
            let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (action) in
                self.databaseReference.child("classes").child(self.classes[indexPath.row].id).child("members").observeSingleEvent(of: .value, with: { (snapshot) in
                    for child in snapshot.children {
                        if let child_snapshot = child as? DataSnapshot {
                            if let member = Poster.init(snapshot: child_snapshot) {
                                if member.id == Auth.auth().currentUser!.uid {
                                    self.databaseReference.child("classes").child(self.classes[indexPath.row].id).child("members").child(child_snapshot.key).removeValue()
                                    self.loadClasses()
                                    break
                                }
                            }
                        }
                    }
                })
            }
            alertController.addAction(yesAction)
            let noAction = UIAlertAction.init(title: "No", style: .cancel) { (action) in
                
            }
            alertController.addAction(noAction)
            self.present(alertController, animated: true, completion: nil)
        } else if editingStyle == .insert {
            
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PostsViewController") as! PostsViewController
        viewController.selectedClass = classes[indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
