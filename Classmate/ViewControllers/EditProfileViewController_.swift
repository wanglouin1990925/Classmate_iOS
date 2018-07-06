//
//  EditProfileViewController.swift
//  Classmate
//
//  Created by Administrator on 7/4/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class EditProfileViewController_: UIViewController, UITableViewDelegate, UITableViewDataSource, SelectYearTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet var photoContainerView: UIView!
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    
    var activeTextField: UITextField?
    var activeTextView: UITextView?
    
    let storageReference = Storage.storage().reference(withPath: "profile")
    let databaseReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profileTableView.tableHeaderView = photoContainerView
        
        editButton.layer.cornerRadius = editButton.bounds.width/2.0
        editButton.clipsToBounds = true
        
        databaseReference.child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
            GlobalVariable.sharedManager.loggedInUser = User.init(snapshot: snapshot)
            self.profileTableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraButton = UIAlertAction(title: "Take a Photo", style: .default, handler: { (action) -> Void in
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
        })
        
        let albumButton = UIAlertAction(title: "Choose a Photo", style: .default, handler: { (action) -> Void in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        })
        
        alertController.addAction(cameraButton)
        alertController.addAction(albumButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        guard let photoImage = photoImageView.image else { return }
        guard let imageData = UIImageJPEGRepresentation(photoImage, 1.0) else { return }
        
        let imageReference = storageReference.child(Auth.auth().currentUser?.uid ?? "")
        imageReference.putData(imageData, metadata: nil) { (meta, error) in
            guard let meta = meta else {
                GlobalFunction.sharedManager.showAlertMessage("Error", error?.localizedDescription)
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 6:
            return 150
        default:
            return 50
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell-Name", for: indexPath)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell-Email", for: indexPath)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell-EmailShow", for: indexPath)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell-School", for: indexPath)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell-Major", for: indexPath)
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell-Year", for: indexPath) as! SelectYearTableViewCell
            cell.delegate = self
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell-Bio", for: indexPath)
            return cell
        default:
            let cell = UITableViewCell.init()
            return cell
        }
    }
    
    func selectYearTableViewCell(_ cell: UITableViewCell, selectClicked: Bool) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let freshButton = UIAlertAction(title: "Freshman", style: .default, handler: { (action) -> Void in
            
        })
        
        let sophomoreButton = UIAlertAction(title: "Sophomore", style: .default, handler: { (action) -> Void in
            print("Delete button tapped")
        })
        
        let juniorButton = UIAlertAction(title: "Junior", style: .default, handler: { (action) -> Void in
            print("Delete button tapped")
        })
        
        let seniorButton = UIAlertAction(title: "Senior", style: .default, handler: { (action) -> Void in
            print("Delete button tapped")
        })
        
        let gradButton = UIAlertAction(title: "Grad Student", style: .default, handler: { (action) -> Void in
            print("Delete button tapped")
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        alertController.addAction(freshButton)
        alertController.addAction(sophomoreButton)
        alertController.addAction(juniorButton)
        alertController.addAction(seniorButton)
        alertController.addAction(gradButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        photoImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: self.profileTableView.contentInset.top, left: 0, bottom: keyboardSize.height, right: 0)
            self.profileTableView.contentInset = contentInsets
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: self.profileTableView.contentInset.top, left: 0, bottom: 0, right: 0)
        self.profileTableView.contentInset = contentInsets
    }
    
}
