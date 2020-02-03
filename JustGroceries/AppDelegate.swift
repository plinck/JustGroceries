//
//  AppDelegate.swift
//  JustGroceries
//
//  Created by Paul Linck on 12/28/18.
//  Copyright © 2018 Paul Linck. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        // Initialize firebase
        FirebaseApp.configure()
        
        // Make the app work offline. Even offline updates that occur across app restarts will apply
        // to Firebase database once a connection is made. Pretty nice.
        Database.database().isPersistenceEnabled = true
        
        // Firestore - DELETE ABOVE firebase stuff after conversion is doe
        // This code is to make sure firestore uses timestamps for dates
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // TODO: - put logic here to delete user from active
        //
    }

}

