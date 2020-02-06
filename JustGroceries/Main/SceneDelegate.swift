//
//  SceneDelegate.swift
//  JustGroceries
//
//  Created by Paul Linck on 2/5/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import UIKit
import SwiftUI

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let _ = (scene as? UIWindowScene) else { return }
    
    // TODO: - Session
    // If you had a .environtmentObject attached to LoginView() originally
    // don't forget to add that onto the ContentView() in the above code.
    if let windowScene = scene as? UIWindowScene {
      self.window = UIWindow(windowScene: windowScene)
      
      let LoginViewController = UIHostingController(rootView: LoginView())
      
      self.window!.rootViewController = LoginViewController
      self.window!.makeKeyAndVisible()
    }
  }
  // ...
}
