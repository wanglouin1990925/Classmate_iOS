//
//  Like.swift
//  Classmate
//
//  Created by Administrator on 7/17/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Like {
    
    let id: String
    let like_date: String
    var like_user: Poster?
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String : AnyObject],
            let like_date = value["like_date"] as? String,
            let like_user = Poster.init(snapshot: snapshot.childSnapshot(forPath: "like_user")) else {
                return nil
        }
        
        self.id = snapshot.key
        self.like_date = like_date
        self.like_user = like_user
    }
    
}
