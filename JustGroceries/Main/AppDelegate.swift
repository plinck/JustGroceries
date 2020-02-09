//
//  AppDelegate.swift
//  JustGroceries
//
//  Created by Paul Linck on 2/6/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
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
        
        // for google signup
        // In your app delegate's application:didFinishLaunchingWithOptions: method,
        // configure the FirebaseApp object and set the sign-in delegate.
        // See: https://firebase.google.com/docs/auth/ios/google-signin
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
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
    
    // Google signin delegate
    // All the follwign methods are for google signin
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url)
    }
    
    // In the app delegate, implement the GIDSignInDelegate protocol
    // to handle the sign-in process by defining the following methods:
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print("Error in google sign:_ didSignInFor: \(error.localizedDescription)")
            return
        }
        
        // In the signIn:didSignInForUser:withError: method, get a Google ID token and Google access token
        // from the GIDAuthentication object and exchange them for a Firebase credential:
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
        // Finally, authenticate with Firebase using the credential:
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Error in google signin Auth.auth().signIn: \(error.localizedDescription)")
                return
            }
            // User is signed in
            print("User: \(authResult?.user.email ?? "noemal"), Successfully signed in via google")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}

