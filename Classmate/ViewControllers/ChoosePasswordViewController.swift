//
//  ChoosePasswordViewController.swift
//  Classmate
//
//  Created by Administrator on 7/3/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

enum SCREEN_TYPE {
    case LOGIN_SCREEN
    case REGISTRATION_SCREEN
}

class ChoosePasswordViewController: UIViewController {

    var screenType: SCREEN_TYPE = SCREEN_TYPE.LOGIN_SCREEN
    var email: String = ""
    var authStateListenerHandle: AuthStateDidChangeListenerHandle? = nil
    var timer: Timer?
    
    @IBOutlet var verificationOverView: UIView!
    @IBOutlet var loginOverView: UIView!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    
    @IBOutlet weak var login_passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if screenType == SCREEN_TYPE.LOGIN_SCREEN {
            loginOverView.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.containerView.bounds.height)
            containerView.addSubview(loginOverView)
        } else if screenType == SCREEN_TYPE.REGISTRATION_SCREEN {
            verificationOverView.removeFromSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func checkVerificationStatus() {
        let password = screenType == SCREEN_TYPE.LOGIN_SCREEN ? login_passwordTextField.text : passwordTextField.text
        Auth.auth().signIn(withEmail: email, password: password!) { (result, error) in
            if error != nil {
                self.checkVerificationStatus()
            } else {
                if Auth.auth().currentUser?.isEmailVerified == true {
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
                    self.navigationController?.pushViewController(viewController, animated: true)
                } else {
                    self.checkVerificationStatus()
                }
            }
        }
    }
    
    @IBAction func termsButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        if screenType == SCREEN_TYPE.REGISTRATION_SCREEN {
            guard let password = passwordTextField.text else { return }
            guard let confirm = confirmTextField.text else { return }
            
            if password != confirm {
                GlobalFunction.sharedManager.showAlertMessage("Error", "Password does not match the confirm password")
            } else {
                GlobalFunction.sharedManager.showProgressView("Signing...")
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    
                    GlobalFunction.sharedManager.hideProgressView()
                    if let error = error {
                        GlobalFunction.sharedManager.showAlertMessage("Error", error.localizedDescription)
                    } else {
                        self.nextButton.isHidden = true
                        
                        self.verificationOverView.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.containerView.bounds.height)
                        self.containerView.addSubview(self.verificationOverView)
                        
                        Auth.auth().currentUser?.sendEmailVerification { (error) in
                            if let error = error {
                                GlobalFunction.sharedManager.showAlertMessage("Error", error.localizedDescription)
                            } else {
                                self.checkVerificationStatus()
                            }
                        }
                    }
                }
            }
        } else {
            guard let login_password = login_passwordTextField.text else { return }
            
            GlobalFunction.sharedManager.showProgressView("Signing...")
            Auth.auth().signIn(withEmail: email, password: login_password) { (result, error) in
                
                GlobalFunction.sharedManager.hideProgressView()
                if let error = error {
                    GlobalFunction.sharedManager.showAlertMessage("Error", error.localizedDescription)
                } else {
                    if Auth.auth().currentUser?.isEmailVerified == true {
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
                        self.navigationController?.pushViewController(viewController, animated: true)
                    } else {
                        self.nextButton.isHidden = true
                        self.verificationOverView.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.containerView.bounds.height)
                        self.containerView.addSubview(self.verificationOverView)
                        
                        Auth.auth().currentUser?.sendEmailVerification { (error) in
                            if let error = error {
                                GlobalFunction.sharedManager.showAlertMessage("Error", error.localizedDescription)
                            } else {
                                self.checkVerificationStatus()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func resendButtonClicked(_ sender: Any) {
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            if let error = error {
                GlobalFunction.sharedManager.showAlertMessage("Error", error.localizedDescription)
            } else {
                
            }
        }
    }
    
    @IBAction func forgotButtonClicked(_ sender: Any) {
        GlobalFunction.sharedManager.showAlertMessageWithOptions("", "Are you sure you want to reset the password?", "No", "Yes") { (completed) in
            if completed {
                Auth.auth().sendPasswordReset(withEmail: self.email, completion: { (error) in
                    if let error = error {
                        GlobalFunction.sharedManager.showAlertMessage("Error", error.localizedDescription)
                    } else {
                        GlobalFunction.sharedManager.showAlertMessage("Check Your Email", "A password reset email has been sent to you. Click the link in the email to reset your password.")
                    }
                })
            }
        }
    }
    
}
