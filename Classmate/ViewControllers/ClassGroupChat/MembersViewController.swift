//
//  MembersViewController.swift
//  Classmate
//
//  Created by Administrator on 7/12/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import FirebaseStorage

class MembersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var members: [Poster] = [Poster]()
    var filtered_members: [Poster] = [Poster]()
    
    let storageReference = Storage.storage().reference()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for member in members {
            filtered_members.append(member)
        }
        
        tableView.reloadData()
        tableView.tableFooterView = UIView.init()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered_members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let photoImageView = cell.viewWithTag(100) as! UIImageView
        photoImageView.layer.cornerRadius = photoImageView.bounds.width/2.0
        photoImageView.clipsToBounds = true
        
        storageReference.child(filtered_members[indexPath.row].photo).getData(maxSize: 10 * 1024 * 1024) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                photoImageView.image = UIImage.init(data: data!)
            }
        }
        
        let nameLabel = cell.viewWithTag(101) as! UILabel
        nameLabel.text = filtered_members[indexPath.row].name
        
        return cell
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            
            self.filtered_members.removeAll()
            for member in self.members {
                if member.name.lowercased().contains(updatedText.lowercased()) || updatedText == "" {
                    self.filtered_members.append(member)
                }
            }
            self.tableView.reloadData()
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.filtered_members.removeAll()
        for member in self.members {
            self.filtered_members.append(member)
        }
        self.tableView.reloadData()
        return true
    }
    
}
