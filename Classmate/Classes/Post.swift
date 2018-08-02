//
//  Post.swift
//  Classmate
//
//  Created by Administrator on 7/16/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Post {
    
    let id: String?
    let class_id: String
    let title: String
    let description: String
    let post_date: String
    let image: String
    let video: String
    let poster: Poster?
    let category: String
    let report_count: Int
    var deleted = 0
    
    var like_count: Int
    var comment_count: Int
    
    init(class_id: String, title: String, description: String, category: String, post_date: String, image: String?, video: String?, like_count: Int, comment_count: Int, report_count: Int, poster: Poster, key: String?) {
        self.id = key
        self.title = title
        self.description = description
        self.category = category
        self.class_id = class_id
        self.post_date = post_date
        self.image = image ?? ""
        self.video = video ?? ""
        self.poster = poster
        self.like_count = like_count
        self.report_count = report_count
        self.comment_count = comment_count
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String : AnyObject],
            let title = value["title"] as? String,
            let description = value["description"] as? String,
            let class_id = value["class_id"] as? String,
            let post_date = value["post_date"] as? String,
            let category = value["category"] as? String,
            let image = value["image"] as? String,
            let video = value["video"] as? String,
            let like_count = value["like_count"] as? Int,
            let comment_count = value["comment_count"] as? Int,
            let poster = Poster.init(snapshot: snapshot.childSnapshot(forPath: "poster")) else {
                return nil
        }
        
        if let id = value["id"] as? String {
            self.id = id
        } else {
            self.id = snapshot.key
        }
        
        if let deleted = value["deleted"] as? Int {
            self.deleted = deleted
        } else {
            self.deleted = 0
        }
        
        if let report_count = value["report_count"] as? Int {
            self.report_count = report_count
        } else {
            self.report_count = 0
        }

        self.title = title
        self.description = description
        self.category = category
        self.class_id = class_id
        self.post_date = post_date
        self.image = image
        self.video = video
        self.poster = poster
        self.like_count = like_count
        self.comment_count = comment_count
    }
    
    mutating func setLikeCount(_ like_count: Int) {
        self.like_count = like_count
    }
    
    func toAnyObject() -> Any {
        guard let post_id = self.id else {
            return [
                "title": title,
                "description": description,
                "category": category ,
                "class_id": class_id,
                "post_date": post_date,
                "image": image,
                "video": video,
                "poster": [
                    "id": poster?.id,
                    "name": poster?.name,
                    "photo": poster?.photo
                ],
                "like_count": like_count,
                "comment_count": comment_count,
                "report_count": report_count
            ]
        }

        return [
            "id": post_id,
            "title": title,
            "description": description,
            "category": category ,
            "class_id": class_id,
            "post_date": post_date,
            "image": image,
            "video": video,
            "poster": [
                "id": poster?.id,
                "name": poster?.name,
                "photo": poster?.photo
            ],
            "like_count": like_count,
            "comment_count": comment_count,
            "report_count": report_count
        ]
    }
    
}
