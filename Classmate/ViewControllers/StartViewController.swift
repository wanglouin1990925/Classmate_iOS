//
//  ViewController.swift
//  Classmate
//
//  Created by Administrator on 7/3/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        startButton.layer.cornerRadius = 15.0
        startButton.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "EnterEmailViewController") as! EnterEmailViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

