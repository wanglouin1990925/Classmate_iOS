//
//  Author.swift
//  Classmate
//
//  Created by Administrator on 7/17/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Poster {
    
    let id: String
    let name: String
    var photo: String
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String : AnyObject],
            let id = value["id"] as? String,
            let name = value["name"] as? String,
            let photo = value["photo"] as? String else {
                return nil
        }
        
        self.id = id
        self.name = name
        self.photo = photo
    }
    
    init(_ id: String, _ name: String, _ photo: String) {
        self.id = id
        self.name = name
        self.photo = photo
    }
    
    func toAnyObject() -> Any {
        return [
            "id": id,
            "name": name,
            "photo": photo
        ]
    }
    
}
