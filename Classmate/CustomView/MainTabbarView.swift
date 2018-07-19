//
//  MainTabbarView.swift
//  Classmate
//
//  Created by Administrator on 7/12/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

protocol MainTabbarViewDelegate: NSObjectProtocol {
    func mainTabbarView(didTabbarItemClicked index: Int)
}

class MainTabbarView: UIView {

    @IBOutlet var contentView: UIView!
    
    var delegate: MainTabbarViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewInit()
    }
    
    private func viewInit() {
        Bundle.main.loadNibNamed("MainTabbarView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    @IBAction func timelineButtonClicked(_ sender: Any) {
        delegate?.mainTabbarView(didTabbarItemClicked: 0)
    }
    
    @IBAction func groupButtonClicked(_ sender: Any) {
        delegate?.mainTabbarView(didTabbarItemClicked: 1)
    }
    
    @IBAction func messageButtonClicked(_ sender: Any) {
        delegate?.mainTabbarView(didTabbarItemClicked: 2)
    }
    
}
