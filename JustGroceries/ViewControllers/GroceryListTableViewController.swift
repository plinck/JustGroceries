//
//  JustGroceries
//
//  Created by Paul Linck on 12/28/18.
//  Copyright © 2018 Paul Linck. All rights reserved.
//

import UIKit
import Firebase

class GroceryListTableViewController: UITableViewController {
    
    // MARK: Constants
    let listToUsers = "ListToUsers"
    
    // MARK: Properties
    var items: [GroceryItem] = []
    var user: User!
    var userCountBarButtonItem: UIBarButtonItem!
    
    // establishes a connection to your Firebase database using the provided path
    // these Firebase properties are referred to as references because
    // they refer to a location in your Firebase database
    // In short, this property allows for saving and syncing of data to the given location.
    let ref = Database.database().reference(withPath: "grocery-items")
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        
        userCountBarButtonItem = UIBarButtonItem(title: "1",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(userCountButtonDidTouch))
        userCountBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = userCountBarButtonItem
        
        user = User(uid: "FakeId", email: "hungry@person.food")
        
        // You retrieve data in Firebase by attaching an asynchronous listener
        // to a reference using observe(_:with:).
        // In this case, we want to sort the items by completion status so we use
        // the firebase queryOrdered(:byChild:) for the "completed key
        // OLD NON-Sorted way ==> ref.observe(.value, with: { snapshot in
        ref.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
            // Store the latest version of the data in a local variable inside the listener’s closure.
            var newItems: [GroceryItem] = []
            
            // The snapshot contains the entire list of grocery items, not just the updates.
            // Using children, you loop through the grocery items.
            for child in snapshot.children {
                // The GroceryItem struct has an initializer that populates its properties using a DataSnapshot.
                // A snapshot’s value is of type AnyObject, and can be a dictionary, array, number, or string.
                // After creating an instance of GroceryItem,
                // it’s added it to the array that contains the latest version of the data.
                if let snapshot = child as? DataSnapshot,
                    let groceryItem = GroceryItem(snapshot: snapshot) {
                    newItems.append(groceryItem)
                }
            }
            
            // Replace items with the latest version of the data,
            // then reload the table view so it displays the latest version
            self.items = newItems
            self.tableView.reloadData()
        })
    }// viewDidLoad
    
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
        
        // Delete from firebase note indexPath.row is grocery item to delete
        // Firebase follows a unidirectional data flow model, so the listener in viewDidLoad()
        // notifies the app of the latest value of the grocery list.
        // A removal of an item triggers a value change.
        if editingStyle == .delete {
            print("items[indexPath.row]:\(items[indexPath.row])")
            let groceryItem = items[indexPath.row]
            groceryItem.ref?.removeValue()
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
            // make sure key is lower case so it always matches
            let groceryItemRef = self.ref.child(text.lowercased())
            
            // set value for the key, remember its just JSON
            groceryItemRef.setValue(groceryItem.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func userCountButtonDidTouch() {
        performSegue(withIdentifier: listToUsers, sender: nil)
    }
}
