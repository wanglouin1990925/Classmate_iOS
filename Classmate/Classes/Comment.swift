//
//  Comment.swift
//  Classmate
//
//  Created by Administrator on 7/17/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Comment {
    
    let id: String
    let comment_date: String
    let comment_like_count: Int
    let comment_report_count: Int
    var comment_user: Poster?
    let comment_description: String
    let class_id: String
    let post_id: String
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String : AnyObject],
            let comment_date = value["comment_date"] as? String,
            let comment_description = value["comment_description"] as? String,
            let class_id = value["class_id"] as? String,
            let post_id = value["post_id"] as? String,
            let comment_like_count = value["comment_like_count"] as? Int,
            let comment_report_count = value["comment_report_count"] as? Int,
            let comment_user = Poster.init(snapshot: snapshot.childSnapshot(forPath: "comment_user")) else {
                return nil
        }
        
        self.id = snapshot.key
        self.comment_date = comment_date
        self.comment_like_count = comment_like_count
        self.comment_report_count = comment_report_count
        self.comment_user = comment_user
        self.comment_description = comment_description
        self.class_id = class_id
        self.post_id = post_id
    }
    
    init(comment_user: Poster, comment_description: String, comment_date: String, comment_like_count: Int, comment_report_count: Int, class_id: String, post_id: String) {
        self.comment_date = comment_date
        self.comment_like_count = comment_like_count
        self.comment_report_count = comment_report_count
        self.comment_user = comment_user
        self.comment_description = comment_description
        self.class_id = class_id
        self.post_id = post_id
        self.id = ""
    }
    
    func toAnyObject() -> Any {
        return [
            "comment_date": comment_date,
            "comment_like_count": comment_like_count,
            "comment_report_count": comment_report_count,
            "comment_description": comment_description,
            "class_id": class_id,
            "post_id": post_id,
            "comment_user": [
                "id": comment_user?.id,
                "name": comment_user?.name,
                "photo": comment_user?.photo
            ]
        ]
    }
    
}
