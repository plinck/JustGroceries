//
//  JustGroceries
//
//  Created by Paul Linck on 12/28/18.
//  Copyright © 2018 Paul Linck. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // MARK: Constants
    let loginToList = "LoginToList"
    
    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    // Monitor firebase login state when view loads to see if they are logged in
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create an authentication observer using addStateDidChangeListener(_:).
        // The block is passed two parameters: auth and user.
        Auth.auth().addStateDidChangeListener() {
            auth, user in
            // Test the value of user. Upon successful user authentication,
            // user is populated with the user’s information.
            // If authentication fails, the variable is nil.
            if user != nil {
                // On successful authentication, perform the segue and clear the text fields’ text.
                // It may seem strange that you don’t pass the user to the next controller,
                // but you’ll see how to get this within GroceryListTableViewController.swift
                self.performSegue(withIdentifier: self.loginToList, sender: nil)
                self.textFieldLoginEmail.text = nil
                self.textFieldLoginPassword.text = nil
            }
        } // end closure
    } // end func viewDidLoad()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Actions
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        // make sure they entered user email and password
        guard
            let email = textFieldLoginEmail.text,
            let password = textFieldLoginPassword.text,
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
    } // loginDidTouch(sender:)
    
    // Allow use to sign up for an account
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        
        // Create user in the firebase auth store if they select save
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            // Get the email and password as supplied by the user from the alert controller
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            
            // Call createUser(withEmail:password:) on the default Firebase auth object
            // passing the email and password.
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
                if error == nil {
                    // If there are no errors, the user account has been created.
                    // However, you still need to authenticate this new user,
                    // so call signIn(withEmail:password:)
                    Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!,
                                       password: self.textFieldLoginPassword.text!)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Build the alert dialog with all fields and actions
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLoginEmail {
            textFieldLoginPassword.becomeFirstResponder()
        }
        if textField == textFieldLoginPassword {
            textField.resignFirstResponder()
        }
        return true
    }
}
