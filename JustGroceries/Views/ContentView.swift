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
        if session.session != nil {
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

}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
#endif
