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

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet var photoContainerView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    let storageReference = Storage.storage().reference()
    let databaseReference = Database.database().reference()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var email_showSwitch: UISwitch!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var selectYearButton: UIButton!
    @IBOutlet weak var bioTextView: UITextView!
    
    var updatedUser: User?
    
    var activeTextField: UITextField?
    var activeTextView: UITextView?
    
    var photoUpdated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        editButton.layer.cornerRadius = editButton.bounds.width/2.0
        editButton.clipsToBounds = true
        
        contentScrollView.contentSize = CGSize.init(width: self.view.bounds.width, height: 795)
        
        if let currentUser = Auth.auth().currentUser {
            databaseReference.child("users").child(currentUser.uid).observeSingleEvent(of: .value) { (snapshot) in
                if let user = User.init(snapshot: snapshot) {
                    GlobalVariable.sharedManager.loggedInUser = user
                    self.updatedUser = user
                    self.showUserData()
                } else {
                    self.photoUpdated = true
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(aNotification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(aNotification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func showUserData() {
        if updatedUser?.year == "" {
            selectYearButton.setTitleColor(UIColor.lightGray, for: .normal)
            selectYearButton.setTitle("Select Year Here", for: .normal)
        } else {
            selectYearButton.setTitleColor(UIColor.black, for: .normal)
            selectYearButton.setTitle(updatedUser?.year, for: .normal)
        }
        
        nameTextField.text = updatedUser?.name
        emailTextField.text = updatedUser?.email
        email_showSwitch.isOn = updatedUser?.email_show ?? false
        schoolTextField.text = updatedUser?.school
        majorTextField.text = updatedUser?.major
        bioTextView.text = updatedUser?.bio
        
        storageReference.child(updatedUser?.photo ?? "").getData(maxSize: 10 * 1024 * 1024) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.photoImageView.image = UIImage.init(data: data!)
            }
        }
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
        if photoUpdated {
            guard let photoImage = photoImageView.image else { return }
            guard let imageData = UIImageJPEGRepresentation(photoImage, 1.0) else { return }
            
            let imageReference = storageReference.child("profile").child(Auth.auth().currentUser?.uid ?? "")
            imageReference.putData(imageData, metadata: nil) { (meta, error) in
                guard let meta = meta else {
                    GlobalFunction.sharedManager.showAlertMessage("Error", error?.localizedDescription)
                    return
                }
                
                guard let name = self.nameTextField.text else { return }
                guard let email = self.emailTextField.text else { return }
                guard let school = self.schoolTextField.text else { return }
                guard let major = self.majorTextField.text else { return }
                guard let bio = self.bioTextView.text else { return }
                let email_show = self.email_showSwitch.isOn
                var year = self.selectYearButton.title(for: .normal) ?? ""
                if year == "Select Year Here" {
                    year = ""
                }
                
                self.updatedUser = User.init(name: name, email: email, email_show: email_show, school: school, major: major, year: year, bio: bio, photo: meta.path ?? "", ref: nil)
                if let currentUser = Auth.auth().currentUser {
                    self.databaseReference.child("users").child(currentUser.uid).setValue(self.updatedUser?.toAnyObject(), withCompletionBlock: { (error, ref) in
                        if let error = error {
                            GlobalFunction.sharedManager.showAlertMessage("Error", error.localizedDescription)
                        } else {
                            GlobalVariable.sharedManager.loggedInUser = User.init(name: name, email: email, email_show: email_show, school: school, major: major, year: year, bio: bio, photo: meta.path!, key: ref.key, ref: ref)
                        }
                    })
                }
            }
        } else {
            guard let name = self.nameTextField.text else { return }
            guard let email = self.emailTextField.text else { return }
            guard let school = self.schoolTextField.text else { return }
            guard let major = self.majorTextField.text else { return }
            guard let bio = self.bioTextView.text else { return }
            let email_show = self.email_showSwitch.isOn
            var year = self.selectYearButton.title(for: .normal) ?? ""
            if year == "Select Year Here" {
                year = ""
            }
            let photo = GlobalVariable.sharedManager.loggedInUser?.photo
            
            self.updatedUser = User.init(name: name, email: email, email_show: email_show, school: school, major: major, year: year, bio: bio, photo: photo!, ref: nil)
            if let currentUser = Auth.auth().currentUser {
                self.databaseReference.child("users").child(currentUser.uid).setValue(self.updatedUser?.toAnyObject(), withCompletionBlock: { (error, ref) in
                    if let error = error {
                        GlobalFunction.sharedManager.showAlertMessage("Error", error.localizedDescription)
                    } else {
                        GlobalVariable.sharedManager.loggedInUser = User.init(name: name, email: email, email_show: email_show, school: school, major: major, year: year, bio: bio, photo: photo!, key: ref.key, ref: ref)
                    }
                })
            }
        }
    }
    
    @IBAction func selectYearButtonClicked(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let freshButton = UIAlertAction(title: "Freshman", style: .default, handler: { (action) -> Void in
            self.selectYearButton.setTitle("Freshman", for: .normal)
            self.selectYearButton.setTitleColor(UIColor.black, for: .normal)
        })
        
        let sophomoreButton = UIAlertAction(title: "Sophomore", style: .default, handler: { (action) -> Void in
            self.selectYearButton.setTitle("Sophomore", for: .normal)
            self.selectYearButton.setTitleColor(UIColor.black, for: .normal)
        })
        
        let juniorButton = UIAlertAction(title: "Junior", style: .default, handler: { (action) -> Void in
            self.selectYearButton.setTitle("Junior", for: .normal)
            self.selectYearButton.setTitleColor(UIColor.black, for: .normal)
        })
        
        let seniorButton = UIAlertAction(title: "Senior", style: .default, handler: { (action) -> Void in
            self.selectYearButton.setTitle("Senior", for: .normal)
            self.selectYearButton.setTitleColor(UIColor.black, for: .normal)
        })
        
        let gradButton = UIAlertAction(title: "Grad Student", style: .default, handler: { (action) -> Void in
            self.selectYearButton.setTitle("Grad Student", for: .normal)
            self.selectYearButton.setTitleColor(UIColor.black, for: .normal)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
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
        photoUpdated = true
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    @objc func keyboardWillShow(aNotification: NSNotification) {
        let info = aNotification.userInfo ?? [:]
        let kbSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
        contentScrollView.contentInset = contentInsets
        contentScrollView.scrollIndicatorInsets = contentInsets
        var aRect: CGRect = self.view.frame
        aRect.size.height -= kbSize.height
        
        if activeTextField != nil {
            if !aRect.contains(activeTextField!.frame.origin) {
                self.contentScrollView.scrollRectToVisible(activeTextField!.frame, animated: true)
            }
        } else if activeTextView != nil {
            if !aRect.contains(activeTextView!.frame.origin) {
                self.contentScrollView.scrollRectToVisible(activeTextView!.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillBeHidden(aNotification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        self.contentScrollView.contentInset = contentInsets
        self.contentScrollView.scrollIndicatorInsets = contentInsets
    }
    
}
