//
//  CreatePostViewController.swift
//  Classmate
//
//  Created by Administrator on 7/12/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

protocol CreatePostViewControllerDelegate: NSObjectProtocol {
    func createPostViewControllerDidPosted()
}

class CreatePostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoContainerView: UIView!
    @IBOutlet weak var categoryContainerView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var limitLabel: UILabel!
    
    var selectedCategory = ""
    var imageData: Data?
    var videoData: NSData?
    var charLimit = 200
    var selectedClass: Class?
    
    let storageReference = Storage.storage().reference()
    let databaseReference = Database.database().reference()
    
    var delegate: CreatePostViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        photoContainerView.layer.cornerRadius = photoContainerView.bounds.height / 2.0
        photoContainerView.clipsToBounds = true
        
        categoryContainerView.layer.cornerRadius = photoContainerView.bounds.height / 2.0
        categoryContainerView.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.screenTapped))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        limitLabel.text = "0/\(charLimit)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func screenTapped() {
        self.view.endEditing(true)
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func upload(_ videoData: Data?, imageData: Data, completion : @escaping (_ success: Bool, _ video: String?, _ image: String?) -> Void) {
        if videoData != nil {
            let videoReference = storageReference.child("group").child("\(Auth.auth().currentUser!.uid)_\(Date().timeIntervalSince1970).mp4")
            let videoMetadata = StorageMetadata.init()
            videoMetadata.cacheControl = "public,max-age=300"
            videoMetadata.contentType = "video/mp4"
            
            videoReference.putData(videoData!, metadata: videoMetadata) { (video_meta, error) in
                guard let video_meta = video_meta else {
                    completion(false, nil, nil)
                    return
                }
                
                let imageReference = self.storageReference.child("group").child("\(Auth.auth().currentUser!.uid)_\(Date().timeIntervalSince1970).jpg")
                let imageMetadata = StorageMetadata.init()
                imageMetadata.cacheControl = "public,max-age=300"
                imageMetadata.contentType = "image/jpeg"
                
                imageReference.putData(imageData, metadata: imageMetadata) { (image_meta, error) in
                    guard let image_meta = image_meta else {
                        completion(false, nil, nil)
                        return
                    }
                    completion(true, video_meta.path!, image_meta.path!)
                }
            }
        } else {
            let imageReference = self.storageReference.child("group").child("\(Auth.auth().currentUser!.uid)_\(Date().timeIntervalSince1970).jpg")
            let imageMetadata = StorageMetadata.init()
            imageMetadata.cacheControl = "public,max-age=300"
            imageMetadata.contentType = "image/jpeg"
            
            imageReference.putData(imageData, metadata: imageMetadata) { (image_meta, error) in
                guard let image_meta = image_meta else {
                    completion(false, nil, nil)
                    return
                }
                completion(true, nil, image_meta.path!)
            }
        }
    }
    
    @IBAction func checkButtonClicked(_ sender: Any) {
        guard let description = descriptionLabel.text else {
            GlobalFunction.sharedManager.showAlertMessage("Error", "Please enter description")
            return
        }
        
        var title = titleLabel.text ?? ""
        if title == "" {
            title = description.subString(startIndex: 0, endIndex: 4)
        }
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let post_date = dateFormatter.string(from: Date())
        
        let class_id = selectedClass!.id
        let category = self.selectedCategory
        
        let poster = Poster.init(Auth.auth().currentUser!.uid, GlobalVariable.sharedManager.loggedInUser!.name, GlobalVariable.sharedManager.loggedInUser!.photo)
        
        let like_count = 0
        let comment_count = 0
        
        if imageData != nil {
            GlobalFunction.sharedManager.showProgressView("Uploading...")
            upload(videoData as Data?, imageData: imageData!) { (success, video, image) in
                GlobalFunction.sharedManager.hideProgressView()
                if success {
                    let post = Post.init(class_id: class_id, title: title, description: description, category: category, post_date: post_date, image: image, video: video, like_count: like_count, comment_count: comment_count, poster: poster, key: nil)
                    
                    self.databaseReference.child("posts").child(self.selectedClass!.id).observeSingleEvent(of: .value, with: { (snapshot) in
                        self.databaseReference.child("posts").child(self.selectedClass!.id).child("\(snapshot.childrenCount)").setValue(post.toAnyObject(), withCompletionBlock: { (error, ref) in
                            if error == nil {
                                let last_post = Post.init(class_id: class_id, title: title, description: description, category: category, post_date: post_date, image: image, video: video, like_count: like_count, comment_count: comment_count, poster: poster, key: ref.key)
                                
                                self.databaseReference.child("classes").child(self.selectedClass!.id).child("last_post").setValue(last_post.toAnyObject())
                                
                                self.delegate?.createPostViewControllerDidPosted()
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    })
                } else {
                    GlobalFunction.sharedManager.showAlertMessage("Error", "An unknown error occured.")
                }
            }
        } else {
            let post = Post.init(class_id: class_id, title: title, description: description, category: category, post_date: post_date, image: nil, video: nil, like_count: like_count, comment_count: comment_count, poster: poster, key: nil)
            
            self.databaseReference.child("posts").child(self.selectedClass!.id).observeSingleEvent(of: .value, with: { (snapshot) in
                self.databaseReference.child("posts").child(self.selectedClass!.id).child("\(snapshot.childrenCount)").setValue(post.toAnyObject(), withCompletionBlock: { (error, ref) in
                    if error == nil {
                        let last_post = Post.init(class_id: class_id, title: title, description: description, category: category, post_date: post_date, image: nil, video: nil, like_count: like_count, comment_count: comment_count, poster: poster, key: ref.key)
                        
                        self.databaseReference.child("classes").child(self.selectedClass!.id).child("last_post").setValue(last_post.toAnyObject())

                        self.delegate?.createPostViewControllerDidPosted()
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            })
        }
    }
    
    @IBAction func photoButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraPhotoButton = UIAlertAction(title: "Take Photo", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                picker.mediaTypes = [kUTTypeImage as String]
                picker.cameraCaptureMode = .photo
                self.present(picker, animated: true, completion: nil)
            } else {
                picker.sourceType = .photoLibrary
                picker.mediaTypes = [kUTTypeImage as String]
                self.present(picker, animated: true, completion: nil)
            }
        })
        
        let cameraVideoButton = UIAlertAction(title: "Take Video", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                picker.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String]
                picker.cameraCaptureMode = .video
                self.present(picker, animated: true, completion: nil)
            } else {
                picker.sourceType = .photoLibrary
                picker.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String]
                self.present(picker, animated: true, completion: nil)
            }
        })
        
        let albumPhotoButton = UIAlertAction(title: "Choose Existing Photo", style: .default, handler: { (action) -> Void in
            picker.sourceType = .photoLibrary
            picker.mediaTypes = [kUTTypeImage as String]
            self.present(picker, animated: true, completion: nil)
        })
        
        let albumVideoButton = UIAlertAction(title: "Choose Existing Video", style: .default, handler: { (action) -> Void in
            picker.sourceType = .photoLibrary
            picker.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String]
            self.present(picker, animated: true, completion: nil)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        })
        
        alertController.addAction(cameraPhotoButton)
        alertController.addAction(cameraVideoButton)
        alertController.addAction(albumPhotoButton)
        alertController.addAction(albumVideoButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func categoryButtonClicked(_ sender: Any) {
        let categories = ["Homework", "Project", "Exam", "Other"]
        
        let alertController = UIAlertController(title: nil, message: "Choose a category", preferredStyle: .actionSheet)
        
        for i in 0..<categories.count {
            let categoryAction = UIAlertAction(title: categories[i], style: .default, handler: { (action) -> Void in
                self.categoryLabel.text = categories[i]
                self.selectedCategory = categories[i]
            })
            alertController.addAction(categoryAction)
        }
        
        if self.selectedCategory != "" {
            let removeButton = UIAlertAction(title: "Remove Category", style: .destructive, handler: { (action) -> Void in
                self.categoryLabel.text = "Select a Category"
                self.selectedCategory = ""
            })
            alertController.addAction(removeButton)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        })
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageData = UIImageJPEGRepresentation(image, 1.0)
            self.videoData = nil
            
            self.thumbnailImageView.image = image
            self.thumbnailImageView.isHidden = false
        }
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            let data = NSData(contentsOf: videoUrl as URL)!
            print("File size before compression: \(Double(data.length / 1048576)) mb")
            compressWithSessionStatusFunc(videoUrl) { (compressedData) in
                if let compressed_data = compressedData {
                    print("File size after compression: \(Double(compressed_data.length / 1048576)) mb")
                    if let thumbnail = self.getThumbnailFrom(path: videoUrl as URL) {
                        self.imageData = UIImageJPEGRepresentation(thumbnail, 1.0)
                        self.videoData = compressed_data
                        
                        DispatchQueue.main.async {
                            self.thumbnailImageView.image = thumbnail
                            self.thumbnailImageView.isHidden = false
                        }
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func getThumbnailFrom(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset1280x720) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
    fileprivate func compressWithSessionStatusFunc(_ videoUrl: NSURL, completion : @escaping (_ url: NSData?) -> Void) {
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".MOV")
        compressVideo(inputURL: videoUrl as URL, outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
//                print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                completion(compressedData)
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .failed:
                completion(nil)
            case .cancelled:
                completion(nil)
            }
        }
    }
    
}

extension CreatePostViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        if updatedText.count <= charLimit {
            limitLabel.text = "\(updatedText.count)/\(charLimit)"
        }
        
        return updatedText.count <= charLimit
    }
    
}
