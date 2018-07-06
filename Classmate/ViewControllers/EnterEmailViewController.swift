//
//  EnterEmailViewController.swift
//  Classmate
//
//  Created by Administrator on 7/3/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EnterEmailViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        
        Auth.auth().fetchProviders(forEmail: email, completion: {
            (providers, error) in
            
            if let error = error {
                GlobalFunction.sharedManager.showAlertMessage("Error", error.localizedDescription)
                print(error.localizedDescription)
            } else if providers != nil {
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ChoosePasswordViewController") as! ChoosePasswordViewController
                viewController.screenType = SCREEN_TYPE.LOGIN_SCREEN
                viewController.email = email
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ChoosePasswordViewController") as! ChoosePasswordViewController
                viewController.screenType = SCREEN_TYPE.REGISTRATION_SCREEN
                viewController.email = email
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        })
    }
    
}
