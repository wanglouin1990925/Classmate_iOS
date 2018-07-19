//
//  MainTabbarViewController.swift
//  Classmate
//
//  Created by Administrator on 7/12/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class MainTabbarViewController: UITabBarController, MainTabbarViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let mainTabbarView = MainTabbarView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 83))
        mainTabbarView.delegate = self
        self.tabBar.addSubview(mainTabbarView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mainTabbarView(didTabbarItemClicked index: Int) {
        self.selectedIndex = index
    }
    
}
