//
//  JustGroceries
//
//  Created by Paul Linck on 12/28/18.
//  Copyright © 2018 Paul Linck. All rights reserved.
//
// NOTE: I am using firebase REALIME database (onl for uses) AND cloud firestore since firestore cant detect presence

import UIKit
import Firebase

class OnlineUsersTableViewController: UITableViewController {
    
    // MARK: Constants
    let userCell = "UserCell"
    
    // MARK: Properties
    var currentUsers: [String] = []
    // firebase reference to all online users
    let usersRef = Database.database().reference(withPath: "online")

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create an observer that listens for children added to the location managed by usersRef.
        // This is different than a value listener because only the added child is passed to the closure.
        usersRef.observe(.childAdded, with: { snap in
            // Append value from snapshot to the local array.
            guard let email = snap.value as? String else { return }
            self.currentUsers.append(email)
            // The current row is always the count of the local array minus one
            // because the indexes managed by the table view are zero-based
            let row = self.currentUsers.count - 1
            // Create an instance NSIndexPath using the calculated row index.
            let indexPath = IndexPath(row: row, section: 0)
            // Insert the row using an animation that causes the cell to be inserted from the top
            self.tableView.insertRows(at: [indexPath], with: .top)
        }) // end closure
        
        // create observer for children deleted from the list so you can remove them
        usersRef.observe(.childRemoved, with: { snap in
            guard let emailToFind = snap.value as? String else { return }
            // find the email in the list of users to delete from tableView
            for (index, email) in self.currentUsers.enumerated() {
                if email == emailToFind {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.currentUsers.remove(at: index)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }) // end closure
        
    } // func viewDidLoad()
    
    // MARK: UITableView Delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath)
        let onlineUserEmail = currentUsers[indexPath.row]
        cell.textLabel?.text = onlineUserEmail
        return cell
    }
    
    // MARK: Actions
    
    @IBAction func signoutButtonPressed(_ sender: AnyObject) {
        // Get the currentUser and create onlineRef using its uid,
        // which is a unique identifier representing the user.
        let user = Auth.auth().currentUser!
        let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
        
        // Call removeValue to delete the value for onlineRef (which shows users that are online)
        // While Firebase automatically adds the user to online upon sign in,
        // it does not remove the user on sign out.
        // Instead, it only removes users when they become disconnected.
        // For this application, it doesn’t make sense to show users as “online” after they log out,
        // so you manually remove them here.
        onlineRef.removeValue {
            (error, _) in
            // if there is an error, just print it
            if let error = error {
                print("Removing online failed: \(error)")
                return
            }
            
            // Call Auth.auth().signOut() to remove the user’s credentials from the keychain.
            // If there isn’t an error, dismiss the view controller. Otherwise, print the error.
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true, completion: nil)
            } catch (let error) {
                print("Auth sign out failed: \(error)")
            }
        } // closure removeValue
    } // end func signoutButtonPressed
} // end class
