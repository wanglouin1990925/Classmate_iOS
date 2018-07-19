//
//  Class.swift
//  Classmate
//
//  Created by Administrator on 7/16/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Class {
    
    let id: String
    let title: String
    var members: [Poster] = [Poster]()
    var last_post: Post?
    
    init(id: String, title: String) {
        self.id = id
        self.title = title
        self.members = [Poster]()
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String : AnyObject],
            let title = value["title"] as? String else {
                return nil
        }
        
        self.id = snapshot.key
        self.title = title
        
        let membersSnapshot = snapshot.childSnapshot(forPath: "members")
        for child in membersSnapshot.children {
            if let childSnapshot = child as? DataSnapshot {
                if let member = Poster.init(snapshot: childSnapshot) {
                    self.members.append(member)
                }
            }
        }
        
        let lastPostSnapshot = snapshot.childSnapshot(forPath: "last_post")
        self.last_post = Post.init(snapshot: lastPostSnapshot)
    }
    
}
