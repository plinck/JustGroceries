//
//  ContentView.swift
//  JustGroceries
//
//  Created by Paul Linck on 2/6/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  //MARK: Properties
  @ObservedObject var session = FirebaseSession()
  
  var body: some View {
    
    NavigationView {
      Group {
        if session.user != nil {
          VStack {
            NavigationLink(destination: LoginView()) {
              Text("Dont click me")
            }
            
            List {
              NavigationLink(destination: LoginView()) {
                Text("Dont click me")
              }
            }
            .navigationBarItems(trailing: Button(action: {
              self.session.logOut()
            }) {
              Text("Logout")
            })
            Button(action: sendEmailVerifyLink) {
                Text("Send Email ve").bold().foregroundColor(.yellow)
            }
            .padding()
            .background(Color.red)
            .cornerRadius(/*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
          }
        } else {
          LoginView()
            .navigationBarItems(trailing: Text(""))
        }

      }
      .onAppear(perform: getUser)
      .navigationBarTitle(Text("Just Groceries").font(.title).foregroundColor(.blue))
      .padding()
    }
  }
  
  //MARK: Functions
  func getUser() {
    session.listen()
  }

func sendEmailVerifyLink() {
    session.sendEmailVerification() { (user, error) in
      if let error = error {
          print("Email verification did not send \(error.localizedDescription)")
      } else {
        print("Email verification did sent to: \(self.session.user?.email ?? "none")")
      }
    }
}

}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
#endif
