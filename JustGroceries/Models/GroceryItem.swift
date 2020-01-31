//
//  JustGroceries
//
//  Created by Paul Linck on 12/28/18.
//  Copyright © 2018 Paul Linck. All rights reserved.
//

import Foundation
import Firebase

struct GroceryItem {
  
  let ref: DatabaseReference?
  let key: String
  let name: String
  let addedByUser: String
  var completed: Bool
  
    init(name: String, addedByUser: String, completed: Bool, key: String = "") {
        self.ref = nil
        self.key = key
        self.name = name
        self.addedByUser = addedByUser
        self.completed = completed
    }
    
    init(name: String, addedByUser: String, completed: Bool, docId: String) {
        self.ref = nil
        self.key = docId
        self.name = name
        self.addedByUser = addedByUser
        self.completed = completed
    }

  init?(snapshot: DataSnapshot) {
    guard
      let value = snapshot.value as? [String: AnyObject],
      let name = value["name"] as? String,
      let addedByUser = value["addedByUser"] as? String,
      let completed = value["completed"] as? Bool else {
      return nil
    }
    
    self.ref = snapshot.ref
    self.key = snapshot.key
    self.name = name
    self.addedByUser = addedByUser
    self.completed = completed
  }
  
  func toAnyObject() -> Any {
    return [
      "name": name,
      "addedByUser": addedByUser,
      "completed": completed
    ]
  }
}
