//
//  FirebaseSession.swift
//  JustGroceries
//
//  Created by Paul Linck on 2/6/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import SwiftUI
import Firebase

class FirebaseSession: ObservableObject {
  
  // MARK: - Properties
  @Published var session: User?
  @Published var isLoggedIn: Bool?
  
  var usersRef: DatabaseReference = Database.database().reference(withPath: "users")
  
  // Create a user reference using a user’s uid,
  // which is generated when Firebase creates an account.
  
  //MARK: Functions
  func listen() {
    Auth.auth().addStateDidChangeListener { (auth, user) in
      if let user = user {
        if let displayName = user.displayName {
          self.session = User(uid: user.uid, email:user.email!, displayName: displayName)
        } else {
          self.session = User(uid: user.uid, email:user.email!, displayName: "New User")
        }
        self.isLoggedIn = true
                
        let userID = user.uid
        let currentUser = self.session!

        // Update the online status in firebase realtime DB for this user if they already exist
        // If they dont already exist, add a new user under users reference
        self.usersRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
          // Just update the online status of the user if it already exists
          self.usersRef.child("\(user.uid)/onlineStatus").setValue(self.isLoggedIn)
        }) { (err) in
          print("User not found on login, so adding to firebase: \(err.localizedDescription)")
          self.createUserInFirestore(currentUser: currentUser, onlineStatus: true)
        }
      } else {
        self.isLoggedIn = false
        self.session = nil
      }
    }
  }//func

  func logIn(email: String, password: String, handler: @escaping AuthDataResultCallback) {
    Auth.auth().signIn(withEmail: email, password: password, completion: handler)
  }
  
  func logOut() {
    try! Auth.auth().signOut()
    self.isLoggedIn = false
    // Update the online status for this user
    self.usersRef.child("\(self.session!.uid)/onlineStatus").setValue(false)

    self.session = nil
  }
  
  // TODO: - Refactor ALL DB Calls to be outside these classes to make them less stickt
  // Add the signed up user to firebase realtime DB
  func createUserInFirestore(currentUser: User, onlineStatus: Bool) {
    // Firebase realtime DB
    // Use this reference to save the current user’s info.
    self.usersRef.child(currentUser.uid).setValue(
      ["email": currentUser.email,
       "fistName": currentUser.firstName,
       "lastName": currentUser.lastName,
       "onlineStatus": onlineStatus
      ]
    )

  }


}
