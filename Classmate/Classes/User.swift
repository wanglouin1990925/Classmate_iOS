//
//  User.swift
//  Classmate
//
//  Created by Administrator on 7/4/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    let ref: DatabaseReference?
    let key: String
    
    let name: String
    let email: String
    let email_show: Bool
    let school: String
    let major: String
    let year: String
    let bio: String
    let photo: String
    
    init(name: String, email: String, email_show: Bool, school: String, major: String, year: String, bio: String, photo: String, key: String = "", ref: DatabaseReference?) {
        self.ref = ref
        self.key = key
        self.name = name
        self.email = email
        self.email_show = email_show
        self.school = school
        self.major = major
        self.year = year
        self.bio = bio
        self.photo = photo
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String : AnyObject],
            let name = value["name"] as? String,
            let email = value["email"] as? String,
            let email_show = value["email_show"] as? Bool,
            let school = value["school"] as? String,
            let major = value["major"] as? String,
            let year = value["year"] as? String,
            let bio = value["bio"] as? String,
            let photo = value["photo"] as? String else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.name = name
        self.email = email
        self.email_show = email_show
        self.school = school
        self.major = major
        self.year = year
        self.bio = bio
        self.photo = photo
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "email": email,
            "email_show": email_show,
            "school": school,
            "major": major,
            "year": year,
            "bio": bio,
            "photo": photo,
        ]
    }
}

