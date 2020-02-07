//
//  LoginView.swift
//  JustGroceries
//
//  Created by Paul Linck on 2/6/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import SwiftUI

struct LoginView: View {
  
  //MARK: Properties
  @State var email: String = ""
  @State var password: String = ""
  
  @EnvironmentObject var session: FirebaseSession
  
  var body: some View {
    VStack() {
      Text("User Login")
      TextField("Email", text: $email)
      
      SecureField("Password", text: $password)
      Button(action: logIn) {
        Text("Sign In")
      }
      .padding()
//      NavigationLink(destination: SignUp()) {
//        Text("Sign Up")
//      }
    }
    .padding()
  }
  
  //MARK: Functions
  func logIn() {
    session.logIn(email: email, password: password) { (result, error) in
      if error != nil {
        print("Error")
      } else {
        self.email = ""
        self.password = ""
      }
    }
  }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
  }
}
#endif
