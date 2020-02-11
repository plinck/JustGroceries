//
//  User.swift
//  JustGroceries
//
//  Created by Paul Linck on 2/6/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import Foundation

class UserProfile: ObservableObject{
    
    var nonce: String?
    
    init() {
        self.nonce = nil
    }
    
    init(nonce: String?) {
        self.nonce = nonce
    }

    // For JSON Output
    func toAnyObject() -> Any {
        return [
            "nonce": nonce
        ]
    }
    
}
