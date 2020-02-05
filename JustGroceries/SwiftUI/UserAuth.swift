//
//  UserAuth.swift
//  JustGroceries
//
//  Created by Paul Linck on 2/4/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import Foundation
import Firebase

class UserAuth {
  
  // MARK: Constants
  let loginToList = "LoginToList"
  
  init() {
    // Monitor lgin state changes
    // The block is passed two parameters: auth and user.
    Auth.auth().addStateDidChangeListener() {
      auth, user in
      // Test the value of user. Upon successful user authentication,
      // user is populated with the user’s information.
      // If authentication fails, the variable is nil.
      if user != nil {
        // On successful authentication, perform the segue to call grocery list view.
        // It may seem strange that you don’t pass the user to the next controller,
        // but you’ll see how to get this within GroceryListTableViewController.swift
        print("User logged in with email: \(String(describing: user?.email)), id: \(String(describing: user?.uid))")
        //self.performSegue(withIdentifier: self.loginToList, sender: nil)
       }
    } // end closure
  } // end func viewDidLoad()
  

  // MARK: Actions
  func login(email: String, password: String) {
    // make sure they entered user email and password
    guard
      email.count > 0,
      password.count > 0
      else {
        return
    }
    
    // use firebase Auth to signin
    Auth.auth().signIn(withEmail: email, password: password) {
     
      user, error in
      // Display erro if failed
      if let error = error, user == nil {
        let alert = UIAlertController(title: "Sign In Failed",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true, completion: nil)
      }
    } // End trailing closure
  } // login
}
