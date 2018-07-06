//
//  GlobalVariable.swift
//  Classmate
//
//  Created by Administrator on 7/4/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation

class GlobalVariable {
    
    var loggedInUser: User?
    
    class var sharedManager : GlobalVariable {
        struct Static {
            static let instance = GlobalVariable()
        }
        return Static.instance
    }
    
}
