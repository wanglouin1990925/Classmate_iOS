//
//  AddClassViewController.swift
//  Classmate
//
//  Created by Administrator on 7/13/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AddClassViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    let databaseReference = Database.database().reference()
    var classes = [Class]()
    var filterd_classes = [Class]()
    
    var groupChatViewController: GroupChatViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView.init()
        self.loadClasses()
    }
    
    func loadClasses() {
        databaseReference.child("classes").observeSingleEvent(of: .value) { (snapshot) in
            self.classes.removeAll()
            self.filterd_classes.removeAll()
            for child in snapshot.children {
                guard let child_snapshot = child as? DataSnapshot else {
                    continue
                }
                if let group = Class.init(snapshot: child_snapshot) {
                    self.classes.append(group)
                    
                    if group.title.lowercased().contains(self.searchTextField.text?.lowercased() ?? "") || self.searchTextField.text == "" {
                        self.filterd_classes.append(group)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.groupChatViewController?.loadClasses()
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterd_classes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let titleLabel = cell.viewWithTag(100) as! UILabel
        titleLabel.text = filterd_classes[indexPath.row].title
        
        if isJoined((Auth.auth().currentUser?.uid)!, filterd_classes[indexPath.row].members) {
            titleLabel.textColor = UIColor.red
        } else {
            titleLabel.textColor = UIColor.black
        }
        
        return cell
    }
    
    func isJoined(_ uid: String, _ members: [Poster]) -> Bool {
        var isJoined = false
        for member in members {
            if member.id == uid {
                isJoined = true
                break
            }
        }
        return isJoined
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isJoined((Auth.auth().currentUser?.uid)!, filterd_classes[indexPath.row].members) {
            let alertController = UIAlertController.init(title: nil, message: "You have already joined \(filterd_classes[indexPath.row].title).", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Ok", style: .default) { (action) in
                
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController.init(title: nil, message: "Add \(filterd_classes[indexPath.row].title) to your courses?", preferredStyle: .actionSheet)
            let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (action) in
                let ref = self.databaseReference.child("classes").child(self.filterd_classes[indexPath.row].id).child("members")
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    let member = Poster.init(Auth.auth().currentUser!.uid, GlobalVariable.sharedManager.loggedInUser!.name, GlobalVariable.sharedManager.loggedInUser!.photo)
                    ref.childByAutoId().setValue(member.toAnyObject(), withCompletionBlock: { (error, ref) in
                        if error == nil {
                            self.loadClasses()
                        }
                    })
                })
            }
            alertController.addAction(yesAction)
            let noAction = UIAlertAction.init(title: "No", style: .cancel) { (action) in
                
            }
            alertController.addAction(noAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            
            self.filterd_classes.removeAll()
            for group in self.classes {
                if group.title.lowercased().contains(updatedText.lowercased()) || updatedText == "" {
                    self.filterd_classes.append(group)
                }
            }
            self.tableView.reloadData()
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.filterd_classes.removeAll()
        for group in self.classes {
            self.filterd_classes.append(group)
        }
        self.tableView.reloadData()
        return true
    }
    
}
