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
  var groceryListener: ListenerRegistration!       // for listeners
  var userListener: ListenerRegistration!
  
  // Firebase reference to all online users
  let usersRef = Database.database().reference(withPath: "online")
  
  // Firestore
  let db = Firestore.firestore()
  let groceryItemReference = Firestore.firestore().collection("grocery-items")
  
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
    
    // Use firebase for users since firestore cant do presense sensing
    // Observer for online users count
    usersRef.observe(.value, with: { snapshot in
      if snapshot.exists() {
        self.userCountBarButtonItem?.title = "Users:\(snapshot.childrenCount.description)"
      } else {
        self.userCountBarButtonItem?.title = "Users:0"
      }
    })
    
    // Attach an authentication observer to the Firebase auth object,
    // which in turn assigns the user property when a user successfully signs in.
    Auth.auth().addStateDidChangeListener { auth, user in
      guard let user = user else { return }
      self.user = User(authData: user)
      
      // Create a child reference using a user’s uid,
      // which is generated when Firebase creates an account.
      let currentUserRef = self.usersRef.child(self.user.uid)
      
      // Use this reference to save the current user’s email.
      currentUserRef.setValue(self.user.email)
      
      // Call onDisconnectRemoveValue() on currentUserRef.
      // This removes the value at the reference’s location after the connection to Firebase closes,
      // e.g. when a user quits app. This is perfect for monitoring users who have gone offline.
      currentUserRef.onDisconnectRemoveValue()
    } // closure
  }// viewDidLoad func
  
  // Setup listeners in view did appear
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Firestore Observer for grocery items
    self.groceryItemReference.order(by: "completed")
    self.groceryListener = self.groceryItemReference.addSnapshotListener {querySnapshot, err in
      guard let groceryDocs = querySnapshot?.documents else {
        print("Error fetching grocery items from firestore: \(err!)")
        return
      }
      // Store the latest version of the data in closure
      var newItems: [GroceryItem] = []
      
      for document in groceryDocs {
        if document.exists {
          print("\(document.documentID) => \(document.data())")
          print("name => \(document.data()["name"] ?? "")")
          print("addedByUser => \(document.data()["addedByUser"] ?? "")")
          print("completed => \(document.data()["completed"] ?? "")")
          guard let name = document.data()["name"] as? String else {continue}
          guard let addedByUser = document.data()["addedByUser"] as? String else {continue}
          guard let completed = document.data()["completed"] as? Bool else {continue}
          let docId = document.documentID
          
          let groceryItem = GroceryItem(name: name,
                                        addedByUser: addedByUser,
                                        completed: completed,
                                        docId: docId)
          newItems.append(groceryItem)
        }
      }
      // Replace items with the latest version of the data,
      // then reload the table view so it displays the latest version
      self.items = newItems
      self.tableView.reloadData()
    }
  }
  
  // remove listeners
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    // Stop listening to changes
    groceryListener.remove()
  }
  
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
    
    if editingStyle == .delete {
      print("items[indexPath.row]:\(items[indexPath.row])")
      let groceryItem = items[indexPath.row]
      
      self.groceryItemReference.document(groceryItem.key).delete() { err in
        if let err = err {
          print("Error deleting user: \(err)")
        } else {
          print("User doc successfully deleted!")
        }
      }
    }
  }
  
  // select row to check it
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Find the cell the user tapped
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    
    // Get the corresponding GroceryItem by using the index path’s row
    let groceryItem = items[indexPath.row]
    
    // Negate completed on the grocery item to toggle the status
    let toggledCompletion = !groceryItem.completed
    
    // Call toggleCellCheckbox(_:isCompleted:) to update the visual properties of the cell
    toggleCellCheckbox(cell, isCompleted: toggledCompletion)
    
    // Add a new user document in collection "users"
    self.groceryItemReference.document(groceryItem.key).setData([
      "completed": toggledCompletion
    ], merge: true) { err in
      if let err = err {
        print("Error writing completed grocery item: \(err)")
      } else {
        print("completed grocery item doc successfully written!")
      }
    }
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
                                    ref = self.groceryItemReference.addDocument(data: [
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
