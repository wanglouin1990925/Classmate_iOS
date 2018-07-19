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

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet var photoContainerView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    let storageReference = Storage.storage().reference()
    let databaseReference = Database.database().reference()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var primaryEmailTextField: UITextField!
    @IBOutlet weak var secondaryEmailTextField: UITextField!
    @IBOutlet weak var email_showSwitch: UISwitch!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var selectYearButton: UIButton!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var selectMajorButton: UIButton!
    
    @IBOutlet var pickerContainerView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var updatedUser: User?
    
    var activeTextField: UITextField?
    var activeTextView: UITextView?
    
    var photoUpdated = false
    var pickerType: String?
    
    var majors: [String] = ["Accounting",
                            "Acting",
                            "Actuarial Science",
                            "Aeronautical and Astronautical Engineering",
                            "Aeronautical Engineering Technology",
                            "Aerospace Financial Analysis",
                            "African American Studies",
                            "Agribusiness (multiple concentrations)",
                            "Agricultural Communication",
                            "Agricultural Economics (multiple concentrations)",
                            "Agricultural Education",
                            "Agricultural Engineering",
                            "Agricultural Engineering",
                            "Agricultural Systems Management",
                            "Agronomy (multiple concentrations)",
                            "Airline Management and Operations",
                            "Airport Management and Operations",
                            "American Studies",
                            "Animal Sciences (multiple concentrations)",
                            "Animation",
                            "Anthropology",
                            "Applied Exercise and Health (Pre)",
                            "Applied Meteorology and Climatology",
                            "Art History",
                            "Asian Studies",
                            "Athletic Training (Pre)",
                            "Atmospheric Science/Meteorology",
                            "Audio Engineering Technology",
                            "Automation and Systems Integration Engineering Technology",
                            "Aviation Management",
                            "Biochemistry",
                            "Biochemistry (Biology)",
                            "Biochemistry (Chemistry)",
                            "Biological Engineering - multiple concentrations",
                            "Biological Engineering - multiple concentrations",
                            "Biology",
                            "Biomedical Engineering",
                            "Brain and Behavioral Sciences",
                            "Building Information Modeling",
                            "Cell, Molecular, and Developmental Biology",
                            "Chemical Engineering",
                            "Chemistry",
                            "Chemistry - American Chemical Society",
                            "Chinese Studies",
                            "Civil Engineering",
                            "Classical Studies",
                            "Communication, General (Pre)",
                            "Comparative Literature",
                            "Computer and Information Technology",
                            "Computer Engineering",
                            "Computer Science",
                            "Construction Engineering",
                            "Construction Management Technology",
                            "Creative Writing",
                            "Crop Science",
                            "Cybersecurity",
                            "Data Science",
                            "Data Visualization",
                            "Design and Construction Integration",
                            "Developmental and Family Science",
                            "Early Childhood Education and Exceptional Needs",
                            "Ecology, Evolution, and Environmental Sciences",
                            "Economics (Pre) (College of Liberal Arts)",
                            "Economics (School of Management)",
                            "Electrical Engineering",
                            "Electrical Engineering Technology",
                            "Elementary Education",
                            "Engineering / Technology Teacher Education",
                            "English",
                            "Environmental and Ecological Engineering",
                            "Environmental and Natural Resources Engineering",
                            "Environmental and Natural Resources Engineering",
                            "Environmental Geosciences",
                            "Environmental Health Sciences",
                            "Environmental Studies (Pre)",
                            "Exploratory Studies (for undecided students)",
                            "Family and Consumer Sciences Education",
                            "Farm Management",
                            "Film and Theatre Production",
                            "Film and Video Studies",
                            "Finance",
                            "Financial Counseling and Planning",
                            "Fisheries and Aquatic Sciences",
                            "Flight (Professional Flight Technology)",
                            "Foods and Nutrition in Business",
                            "Food Science",
                            "Forestry",
                            "French",
                            "Game Development and Design",
                            "General Education: Curriculum and Instruction (non-licensure)",
                            "General Education: Educational Studies (non-licensure)",
                            "Genetic Biology",
                            "Geology and Geophysics",
                            "German",
                            "Global Studies",
                            "Health and Disease",
                            "Health Sciences - Preprofessional",
                            "History",
                            "Horticulture (multiple concentrations)",
                            "Hospitality and Tourism Management",
                            "Human Resource Development",
                            "Human Services",
                            "Industrial (Consumer Product) Design",
                            "Industrial Engineering",
                            "Industrial Engineering Technology",
                            "Industrial Management",
                            "Insect Biology",
                            "Integrated Studio Arts",
                            "Interdisciplinary Engineering Studies",
                            "Interior (Space Planning) Design",
                            "Italian Studies",
                            "Japanese",
                            "Jewish Studies",
                            "Kinesiology",
                            "Landscape Architecture (Pre)",
                            "Law and Society",
                            "Learning Sciences in Educational Studies (non licensure)",
                            "Linguistics",
                            "Management (General)",
                            "Marketing",
                            "Materials Engineering",
                            "Mathematics",
                            "Mathematics Education",
                            "Mechanical Engineering",
                            "Mechanical Engineering Technology",
                            "Mechatronics Engineering Technology",
                            "Medical Laboratory Sciences",
                            "Medieval and Renaissance Studies",
                            "Microbiology",
                            "Multidisciplinary Engineering",
                            "Natural Resources and Environmental Science (multiple concentrations)",
                            "Network Engineering Technology",
                            "Neurobiology and Physiology",
                            "Nuclear Engineering",
                            "Nursing",
                            "Nutrition, Fitness, and Health",
                            "Nutrition and Dietetics",
                            "Nutrition and Dietetics/Nutrition, Fitness and Health (dual major)",
                            "Nutrition Science",
                            "Occupational Health Science",
                            "Organizational Leadership",
                            "Pharmacy",
                            "Philosophy",
                            "Physics",
                            "Planetary Sciences",
                            "Plant Genetics, Breeding, and Biotechnology",
                            "Plant Science",
                            "Political Science",
                            "Predentistry",
                            "Prelaw",
                            "Premedicine",
                            "Preoccupational Therapy",
                            "Prephysical Therapy",
                            "Prephysician's Assistant",
                            "Pre-veterinary Medicine",
                            "Professional Writing",
                            "Psychological Sciences",
                            "Public Health",
                            "Purdue Polytechnic Institute Statewide Programs",
                            "Radiological Health Sciences - Health Physics",
                            "Radiological Health Sciences - Pre-Medical Physics",
                            "Religious Studies",
                            "Retail Management",
                            "Robotics Engineering Technology",
                            "Russian",
                            "Sales and Marketing",
                            "Science Education (Biology, Chemistry, Earth/Space, Physics)",
                            "Selling and Sales Management",
                            "Social Studies Education",
                            "Sociology",
                            "Soil and Water Sciences",
                            "Sound for the Performing Arts",
                            "Spanish",
                            "Special Education: Dual Licensure in Elementary Education and Special Education - Mild Intervention",
                            "Special Education: Mild and Intense Intervention P-12",
                            "Special Education: Mild Intervention P-12",
                            "Speech, Language, and Hearing Sciences",
                            "Statistics - Applied Statistics",
                            "Statistics with Mathematics Option",
                            "Studio Arts and Technology",
                            "Supply Chain Information and Analytics",
                            "Supply Chain Management Technology",
                            "Sustainable Biomaterials – Process and Product Design",
                            "Sustainable Food and Farming Systems",
                            "Systems Analysis and Design",
                            "Theatre",
                            "Theatre Design and Production",
                            "Transdisciplinary Studies in Engineering Technology",
                            "Transdisciplinary Studies in Technology",
                            "Turf Management and Science",
                            "Undecided Liberal Arts",
                            "Undecided within Engineering",
                            "Unmanned Aerial Systems",
                            "UX Design",
                            "Veterinary Technician or Technologist",
                            "Virtual Product Integration",
                            "Visual Arts Design Education",
                            "Visual Arts Education",
                            "Visual Communications Design",
                            "Visual Effects Compositing",
                            "Web Programming and Design",
                            "Wildlife",
                            "Women’s, Gender and Sexuality Studies"]
    var years: [String] = ["Freshman", "Sophomore", "Junior", "Senior", "Grad Student"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        editButton.layer.cornerRadius = editButton.bounds.width/2.0
        editButton.clipsToBounds = true
        
        contentScrollView.contentSize = CGSize.init(width: self.view.bounds.width, height: 840)
        
        if let currentUser = Auth.auth().currentUser {
            databaseReference.child("users").child(currentUser.uid).observeSingleEvent(of: .value) { (snapshot) in
                if let user = User.init(snapshot: snapshot) {
                    GlobalVariable.sharedManager.loggedInUser = user
                    self.updatedUser = user
                    self.showUserData()
                } else {
                    self.photoUpdated = true
                    self.primaryEmailTextField.text = currentUser.email
                    self.schoolTextField.text = self.getSchool(currentUser.email!)
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
    
    @IBAction func pickerCancelButtonClicked(_ sender: Any) {
        pickerContainerView.removeFromSuperview()
    }
    
    @IBAction func pickerSelectButtonClicked(_ sender: Any) {
        pickerContainerView.removeFromSuperview()
        
        switch pickerType {
        case "YEAR":
            selectYearButton.setTitle(years[pickerView.selectedRow(inComponent: 0)], for: .normal)
            selectYearButton.setTitleColor(UIColor.black, for: .normal)
        case "MAJOR":
            selectMajorButton.setTitle(majors[pickerView.selectedRow(inComponent: 0)], for: .normal)
            selectMajorButton.setTitleColor(UIColor.black, for: .normal)
        default:
            break
        }
    }
    
    func getSchool(_ email: String) -> String {
        return "Purdue University"
    }
    
    func showUserData() {
        if updatedUser?.year == "" {
            selectYearButton.setTitleColor(UIColor.lightGray, for: .normal)
            selectYearButton.setTitle("Select Year Here", for: .normal)
        } else {
            selectYearButton.setTitleColor(UIColor.black, for: .normal)
            selectYearButton.setTitle(updatedUser?.year, for: .normal)
        }
        
        if updatedUser?.major == "" {
            selectMajorButton.setTitleColor(UIColor.lightGray, for: .normal)
            selectMajorButton.setTitle("Select Major Here", for: .normal)
        } else {
            selectMajorButton.setTitleColor(UIColor.black, for: .normal)
            selectMajorButton.setTitle(updatedUser?.major, for: .normal)
        }
        
        nameTextField.text = updatedUser?.name
        primaryEmailTextField.text = updatedUser?.primary_email
        secondaryEmailTextField.text = updatedUser?.secondary_email
        email_showSwitch.isOn = updatedUser?.email_show ?? false
        schoolTextField.text = updatedUser?.school
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
            guard let name = self.nameTextField.text else { return }
            guard let primary_email = self.primaryEmailTextField.text else { return }
            guard let secondary_email = self.secondaryEmailTextField.text else { return }
            guard let school = self.schoolTextField.text else { return }
            guard let bio = self.bioTextView.text else { return }
            let email_show = self.email_showSwitch.isOn
            
            var year = self.selectYearButton.title(for: .normal) ?? ""
            if year == "Select Year Here" {
                year = ""
            }
            
            var major = self.selectMajorButton.title(for: .normal) ?? ""
            if major == "Select Major Here" {
                major = ""
            }
            
            guard let photoImage = photoImageView.image else { return }
            guard let imageData = UIImageJPEGRepresentation(photoImage, 1.0) else { return }
            
            if name == "" {
                GlobalFunction.sharedManager.showAlertMessage("Error", "Please enter a name")
                return
            }
            
            if secondary_email == "" {
                GlobalFunction.sharedManager.showAlertMessage("Error", "Please enter a secondary email address")
                return
            }
            
            if major == "" {
                GlobalFunction.sharedManager.showAlertMessage("Error", "Please select a major")
                return
            }
            
            if year == "" {
                GlobalFunction.sharedManager.showAlertMessage("Error", "Please select a year")
                return
            }
            
            if photoImage == UIImage.init(named: "Image_avatar") {
                GlobalFunction.sharedManager.showAlertMessage("Error", "Please add a photo")
                return
            }
            
//            self.updatedUser = User.init(name: name, primary_email: primary_email, secondary_email: secondary_email, email_show: email_show, school: school, major: major, year: year, bio: bio, photo: "photo/asfsd", ref: nil)
//            if let currentUser = Auth.auth().currentUser {
//                self.databaseReference.child("users").child(currentUser.uid).setValue(self.updatedUser?.toAnyObject(), withCompletionBlock: { (error, ref) in
//
//                    GlobalFunction.sharedManager.hideProgressView()
//                    if let error = error {
//                        GlobalFunction.sharedManager.showAlertMessage("Error", error.localizedDescription)
//                    } else {
//                        GlobalVariable.sharedManager.loggedInUser = User.init(name: name, primary_email: primary_email, secondary_email: secondary_email, email_show: email_show, school: school, major: major, year: year, bio: bio, photo: "photo/asfsd", key: ref.key, ref: ref)
//                        AppDelegate().sharedInstance().loginAction()
//                    }
//                })
//            }
            
            GlobalFunction.sharedManager.showProgressView("Saving...")
            let imageReference = storageReference.child("profile").child(Auth.auth().currentUser?.uid ?? "")
            imageReference.putData(imageData, metadata: nil) { (meta, error) in
                guard let meta = meta else {
                    GlobalFunction.sharedManager.hideProgressView()
                    GlobalFunction.sharedManager.showAlertMessage("Error", error?.localizedDescription)
                    return
                }

                self.updatedUser = User.init(name: name, primary_email: primary_email, secondary_email: secondary_email, email_show: email_show, school: school, major: major, year: year, bio: bio, photo: meta.path!, ref: nil)
                if let currentUser = Auth.auth().currentUser {
                    self.databaseReference.child("users").child(currentUser.uid).setValue(self.updatedUser?.toAnyObject(), withCompletionBlock: { (error, ref) in

                        GlobalFunction.sharedManager.hideProgressView()
                        if let error = error {
                            GlobalFunction.sharedManager.showAlertMessage("Error", error.localizedDescription)
                        } else {
                            GlobalVariable.sharedManager.loggedInUser = User.init(name: name, primary_email: primary_email, secondary_email: secondary_email, email_show: email_show, school: school, major: major, year: year, bio: bio, photo: meta.path!, key: ref.key, ref: ref)
                            AppDelegate().sharedInstance().loginAction()
                        }
                    })
                }
            }
        } else {
            guard let name = self.nameTextField.text else { return }
            guard let primary_email = self.primaryEmailTextField.text else { return }
            guard let secondary_email = self.secondaryEmailTextField.text else { return }
            guard let school = self.schoolTextField.text else { return }
            guard let bio = self.bioTextView.text else { return }
            let email_show = self.email_showSwitch.isOn
            
            var year = self.selectYearButton.title(for: .normal) ?? ""
            if year == "Select Year Here" {
                year = ""
            }
            
            var major = self.selectMajorButton.title(for: .normal) ?? ""
            if major == "Select Major Here" {
                major = ""
            }
            
            let photo = GlobalVariable.sharedManager.loggedInUser?.photo
            
            if name == "" {
                GlobalFunction.sharedManager.showAlertMessage("Error", "Please enter a name")
                return
            }
            
            if secondary_email == "" {
                GlobalFunction.sharedManager.showAlertMessage("Error", "Please enter a secondary email address")
                return
            }
            
            if major == "" {
                GlobalFunction.sharedManager.showAlertMessage("Error", "Please select a major")
                return
            }
            
            if year == "" {
                GlobalFunction.sharedManager.showAlertMessage("Error", "Please select a year")
                return
            }
            
            GlobalFunction.sharedManager.showProgressView("Saving...")
            self.updatedUser = User.init(name: name, primary_email: primary_email, secondary_email: secondary_email, email_show: email_show, school: school, major: major, year: year, bio: bio, photo: photo!, ref: nil)
            if let currentUser = Auth.auth().currentUser {
                self.databaseReference.child("users").child(currentUser.uid).setValue(self.updatedUser?.toAnyObject(), withCompletionBlock: { (error, ref) in
                    
                    GlobalFunction.sharedManager.hideProgressView()
                    if let error = error {
                        GlobalFunction.sharedManager.showAlertMessage("Error", error.localizedDescription)
                    } else {
                        GlobalVariable.sharedManager.loggedInUser = User.init(name: name, primary_email: primary_email, secondary_email: secondary_email, email_show: email_show, school: school, major: major, year: year, bio: bio, photo: photo!, key: ref.key, ref: ref)
                        AppDelegate().sharedInstance().loginAction()
                    }
                })
            }
        }
    }
    
    @IBAction func selectMajorButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        
        pickerType = "MAJOR"
        pickerView.reloadAllComponents()
        
        pickerContainerView.frame = CGRect.init(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(pickerContainerView)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.pickerContainerView.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }) { (competed) in
            
        }
    }
    
    @IBAction func selectYearButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        
        pickerType = "YEAR"
        pickerView.reloadAllComponents()
        
        pickerContainerView.frame = CGRect.init(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(pickerContainerView)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.pickerContainerView.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }) { (competed) in
            
        }
        
//        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let freshButton = UIAlertAction(title: "Freshman", style: .default, handler: { (action) -> Void in
//            self.selectYearButton.setTitle("Freshman", for: .normal)
//            self.selectYearButton.setTitleColor(UIColor.black, for: .normal)
//        })
//
//        let sophomoreButton = UIAlertAction(title: "Sophomore", style: .default, handler: { (action) -> Void in
//            self.selectYearButton.setTitle("Sophomore", for: .normal)
//            self.selectYearButton.setTitleColor(UIColor.black, for: .normal)
//        })
//
//        let juniorButton = UIAlertAction(title: "Junior", style: .default, handler: { (action) -> Void in
//            self.selectYearButton.setTitle("Junior", for: .normal)
//            self.selectYearButton.setTitleColor(UIColor.black, for: .normal)
//        })
//
//        let seniorButton = UIAlertAction(title: "Senior", style: .default, handler: { (action) -> Void in
//            self.selectYearButton.setTitle("Senior", for: .normal)
//            self.selectYearButton.setTitleColor(UIColor.black, for: .normal)
//        })
//
//        let gradButton = UIAlertAction(title: "Grad Student", style: .default, handler: { (action) -> Void in
//            self.selectYearButton.setTitle("Grad Student", for: .normal)
//            self.selectYearButton.setTitleColor(UIColor.black, for: .normal)
//        })
//
//        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
//
//        })
//
//        alertController.addAction(freshButton)
//        alertController.addAction(sophomoreButton)
//        alertController.addAction(juniorButton)
//        alertController.addAction(seniorButton)
//        alertController.addAction(gradButton)
//        alertController.addAction(cancelButton)
//
//        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        photoImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        photoUpdated = true
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerType {
            case "YEAR":
                return years.count
            case "MAJOR":
                return majors.count
            default:
                return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerType {
            case "YEAR":
                return years[row]
            case "MAJOR":
                return majors[row]
            default:
                return ""
        }
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

extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        activeTextField = nil
        return true
    }
    
}

extension EditProfileViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeTextView = textView
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        activeTextView = nil
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        return updatedText.count <= 100
    }
    
}
