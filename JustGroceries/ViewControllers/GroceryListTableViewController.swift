//
//  JustGroceries
//
//  Created by Paul Linck on 12/28/18.
//  Copyright © 2018 Paul Linck. All rights reserved.
//

// FIXME: - FIX the fact that things are not added to tableview wgen aded to firestiore
// TODO: - Screen is BLACK on iOS device vs simulator
import UIKit
import Firebase

class GroceryListTableViewController: UITableViewController {
    
    // MARK: Constants
    let toOnlineUsers = "ToOnlineUsers"     // Seque to list which users are online
    
    // MARK: Properties
    var items: [GroceryItem] = []
    var user: User!
    var userCountBarButtonItem: UIBarButtonItem!
    
    // Firestore
    let db = Firestore.firestore()
    let groceryItemReference = Firestore.firestore().collection("grocery-items")
    let userReference = Firestore.firestore().collection("users")

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        
        userCountBarButtonItem = UIBarButtonItem(title: "Users:1",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(userCountButtonDidTouch))
        userCountBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = userCountBarButtonItem
        
        // Get items from Firestore
        self.groceryItemReference.order(by: "completed")
        self.groceryItemReference.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting grocery-items: \(err)")
            } else {
                // Store the latest version of the data in closure
                var newItems: [GroceryItem] = []

                for document in querySnapshot!.documents {
                    let groceryItem = GroceryItem(name: document.data()["name"] as! String,
                                                  addedByUser: document.data()["addedByUser"] as! String,
                                                  completed: document.data()["completed"] as! Bool,
                                                  docId: document.documentID)
                    newItems.append(groceryItem)
                    
                    print("\(document.documentID) => \(document.data())")
                }
                // Replace items with the latest version of the data,
                // then reload the table view so it displays the latest version
                self.items = newItems
                self.tableView.reloadData()
            }
        }
        
        // Firestore Observer for online users count
        // This is terribly inefficient or mow and not even importtant so I will
        // eventually delete
        db.collection("users").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching users: \(error!)")
                return
            }
            var count = 0;
            for _ in documents {
                count += 1
            }
            self.userCountBarButtonItem?.title = "Users:\(count)"
        }
        
        // Attach an authentication observer to the Firebase auth object,
        // which in turn assigns the user property when a user successfully signs in.
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else {
                // Delete user from firestore if logout
                // not sure if this does what I want but firestore does not
                // support  detecting "presence." - you need firebase realtime for that
                
                // Unfortuantelt this only works if someone specifically logs out
                // it does not work if they just close the app
                
                self.userReference.document(self.user.uid).delete() { err in
                    if let err = err {
                        print("Error deleting user: \(err)")
                    } else {
                        print("User doc successfully deleted!")
                    }
                }
                return
            }
            self.user = User(authData: user)
                        
            // Add a new user document in collection "users"
            self.userReference.document(self.user.uid).setData([
                "email": self.user.email
            ]) { err in
                if let err = err {
                    print("Error writing user: \(err)")
                } else {
                    print("User doc successfully written!")
                }
            }
        } // Auth.auth() closure
    }// viewDidLoad func
    
    // MARK: UITableView Delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // put the grocery item in the table row
    // note the groceryitem object/struct contains the firebase ref info as well as fields
    // I think it would be best to separate the true data with firebase ref so can be used in other DBs
    // Right now, the toAnyObject method converts it to an object not tied to firebase - i.e. just the values
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let groceryItem = items[indexPath.row]
        
        cell.textLabel?.text = groceryItem.name
        cell.detailTextLabel?.text = groceryItem.addedByUser
        
        toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
        
        return cell
    }
    
    // allow editing row - e.g. slide to delete
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // After selecting delete from tableView, delete from DB
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // Delete from firebase. note indexPath.row is grocery item to delete
        // MARK: - Markme  is this getting deleted from firestore?  I dont get ut.  I
        // FIXME: - Fixme How is this getting deleted from firestore?  I dont get ut.  I
        // TODO: - ToDo How is this getting deleted from firestore?  I dont get ut.  I
        // dont see delete anywhere in my code
        // Firebase follows a unidirectional data flow model, so the listener in
        // viewDidLoad() notifies the app of the latest value of the grocery list.
        // A removal of an item triggers a value change.
        
        // TODO: - Doc is now getting deleted from firestore but NOT from tableView
        if editingStyle == .delete {
            print("items[indexPath.row]:\(items[indexPath.row])")
            let groceryItem = items[indexPath.row]

            self.groceryItemReference.document(groceryItem.key).delete() { err in
                 if let err = err {
                     print("Error deleting user: \(err)")
                 } else {
                    self.items.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    print("User doc successfully deleted!")
                 }
             }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Find the cell the user tapped
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        // Get the corresponding GroceryItem by using the index path’s row
        let groceryItem = items[indexPath.row]
        
        // Negate completed on the grocery item to toggle the status
        let toggledCompletion = !groceryItem.completed
        
        // Call toggleCellCheckbox(_:isCompleted:) to update the visual properties of the cell
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        
        // Use updateChildValues(_:), passing a dictionary, to update Firebase.
        // This method is different than setValue(_:) because it only applies updates,
        // whereas setValue(_:) is destructive and replaces the entire value at that reference
        groceryItem.ref?.updateChildValues([
            "completed": toggledCompletion
            ])
    }
    
    // Change the visual properties of the cell to indicate whether you bought it or not
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = .gray
            cell.detailTextLabel?.textColor = .gray
        }
    }
    
    // MARK: Add Item
    
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Grocery Item",
                                      message: "Add an Item",
                                      preferredStyle: .alert)
        
        // Save to firebase
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { _ in
            // get the first text field from the alert controller
            guard let textField = alert.textFields?.first,
                let text = textField.text else { return }
            
            // create the grocery item object
            let groceryItem = GroceryItem(name: text,
                                          addedByUser: self.user.email,
                                          completed: false)
            // Add a new document to firestore with a generated ID
            var ref: DocumentReference? = nil
            ref = self.db.collection("grocery-items").addDocument(data: [
                "addedByUser": groceryItem.addedByUser,
                "completed": groceryItem.completed,
                "grocery-list": "publix",
                "name": groceryItem.name
            ]) { err in
                if let err = err {
                    print("Error adding grocery item: \(err)")
                } else {
                    print("Grocery Item added with ID: \(ref!.documentID)")
                }
            }
    }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func userCountButtonDidTouch() {
        performSegue(withIdentifier: toOnlineUsers, sender: nil)
    }
}
