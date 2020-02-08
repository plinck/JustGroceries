//
//  User.swift
//  JustGroceries
//
//  Created by Paul Linck on 2/6/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import Foundation

class User {
    
    var uid: String
    var email: String
    var firstName: String
    var lastName: String
    var displayName: String
    
    init(uid: String, email: String, firstName: String, lastName: String) {
        self.uid = uid
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.displayName = "\(firstName) \(lastName)"
    }
    
    init(uid: String, email: String, displayName: String) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        
        let fullNameArr = displayName.components(separatedBy: " ")
        self.firstName = fullNameArr.count > 0 ? fullNameArr[0] : ""
        self.lastName = fullNameArr.count > 1 ? fullNameArr[1] : ""
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
        self.displayName = "Generated UserName"
        
        let fullNameArr = displayName.components(separatedBy: " ")
        self.firstName = fullNameArr.count > 0 ? fullNameArr[0] : ""
        self.lastName = fullNameArr.count > 1 ? fullNameArr[1] : ""
    }
    
    // For JSON Output
    func toAnyObject() -> Any {
        return [
            "uid": uid,
            "email": email,
            "firstName": firstName,
            "lastName": lastName
        ]
    }
    
}
