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
                    if (snapshot.exists() && snapshot.hasChildren()) {
                        // self.printDebugUserSnap(snapshot: snapshot)
                        
                        // Update the online status of the user if it already exists
                        print("User \(userID) exists, updating online status")
                        self.usersRef.child("\(user.uid)/onlineStatus").setValue(self.isLoggedIn)
                        
                        // Possibly update other fields
                        // Create a dictionary of the child values (i.e. JSON format)
                        let dict = snapshot.value as! [String: Any?]
                        // If the email does not exist, act like its a create
                        if let email = dict["email"] {
                            print("Email \(email ?? "noemail") already exists for user \(userID)")
                            // no-op
                        } else {
                            print("Adding email \(user.email ?? "noemail") for user \(userID)")
                            self.usersRef.child("\(user.uid)/email").setValue(user.email)
                        }
                        
                    } else {
                        print("User \(userID) does not exist, adding")
                        self.createUserInFirestore(user: currentUser, onlineStatus: true)
                    }
                }) { (err) in
                    print("Error found on login, so adding to firebase: \(err.localizedDescription)")
                }
            } else {
                self.isLoggedIn = false
                self.session = nil
            }
        }
    }//func
    
    // Login to firebase Auth
    func logIn(email: String, password: String, handler: @escaping AuthDataResultCallback) {
        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
    }
    
    // Logout whih kills session
    func logOut() {
        try! Auth.auth().signOut()
        self.isLoggedIn = false
        // Update the online status for this user
        self.usersRef.child("\(self.session!.uid)/onlineStatus").setValue(false)
        
        self.session = nil
    }
    
    // Sign up for account
    // TODO: - Add Google and Apple ID signin
    func signUp(email: String, password: String,
                firstName: String,
                lastName: String,
                handler: @escaping AuthDataResultCallback) {
        
        let displayName = "\(firstName) \(lastName)"

        // Auth.auth().createUser(withEmail: email, password: password, completion: handler)
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil && user != nil {
                print("User created, updating profile: \(error?.localizedDescription ?? "")")
                
                // Update user profile for displayName (and later do URL of user image using cloud storage)
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = displayName
                changeRequest?.commitChanges { error in
                    handler(user, error)
                }
            } else {
                // Invoke callbackl from original function call
                print("Error creating user: \(error?.localizedDescription ?? "")")
                handler(user, error)
            }
        }

    }    
    
    // TODO: - Refactor ALL DB Calls to be outside these classes to make them less stickt
    // Add the signed up user to firebase realtime DB
    func createUserInFirestore(user: User, onlineStatus: Bool) {
        // Firebase realtime DB
        // Use this reference to save the current user’s info.
        self.usersRef.child(user.uid).setValue(
            ["email": user.email,
             "fistName": user.firstName,
             "lastName": user.lastName,
             "onlineStatus": onlineStatus
            ]
        )
        
    }
}

// Extra Methods
extension FirebaseSession {
    
    func printDebugUserSnap(snapshot: DataSnapshot) {
        print("Child Count: \(snapshot.childrenCount)")
        print("------------")
        
        print ("Snapshot: \(snapshot)")
        let dict = snapshot.value as! [String: Any?]
        if let email = dict["email"] {
            print("Email: \(email ?? "noemail")")
        }
        
        print("Children")
        print("------------")
        for child in snapshot.children {
            let snap = child as! DataSnapshot
            let key = snap.key
            let value = snap.value
            print("key = \(key)  value = \(value!)")
        }
    }
}
