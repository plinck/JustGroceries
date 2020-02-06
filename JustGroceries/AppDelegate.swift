//
//  AppDelegate.swift
//  JustGroceries
//
//  Created by Paul Linck on 2/6/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import UIKit
import Firebase
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
        // In iOS 13, it is handled by scene delegate
    if #available(iOS 13.0, *) { } else {
      self.window = UIWindow(frame: UIScreen.main.bounds)
      // Create the SwiftUI view that provides the window contents.
      let contentView = ContentView()

      self.window!.rootViewController = UIHostingController(rootView: contentView)

      self.window!.makeKeyAndVisible()
    }
    
    // Initialize firebase
    FirebaseApp.configure()
    
    // Make the app work offline. Even offline updates that occur across app restarts will apply
    // to Firebase database once a connection is made. Pretty nice.
    Database.database().isPersistenceEnabled = true
    
    // Firestore - DELETE ABOVE firebase stuff after conversion is doe
    // This code is to make sure firestore uses timestamps for dates
    let db = Firestore.firestore()
    let settings = db.settings
    // deprecated --- settings.areTimestampsInSnapshotsEnabled = true
    //settings.isPersistenceEnabled = false
    db.settings = settings
    
    // With this change, timestamps stored in Cloud Firestore will be read back as
    // Firebase Timestamp objects instead of as system Date objects. So you will also
    // need to update code expecting a Date to instead expect a Timestamp. For example:
    // old:
    // let date: Date = documentSnapshot.get("created_at") as! Date
    // new:
    // let timestamp: Timestamp = documentSnapshot.get("created_at") as! Timestamp
    // let date: Date = timestamp.dateValue()
  
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }


}

