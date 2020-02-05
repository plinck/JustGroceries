//
//  LoginView.swift
//  JustGroceries
//
//  Created by Paul Linck on 2/4/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import SwiftUI

struct LoginView: View {
  @State private var emailAddress = ""
  @State private var password = ""
  
  var body: some View {
    
    ZStack {
      SwiftUI.Color.blue
        .edgesIgnoringSafeArea(.all)
            
      VStack(alignment: .center, spacing: 8.0) {
        
        
        
        Text("Just Groceries")
          .font(.title)
          .foregroundColor(.white)

        Group {
            TextField("nobody@email.com", text: $emailAddress)
              .font(.subheadline)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .frame(width: 300, height: 60)
            SecureField("", text: $password)
              .font(.subheadline)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .frame(width: 300, height: 60)
        }
        
        Button(action: {
          print("Login Tapped")
        }) {
          HStack {
            Image(systemName: "person.fill")
              .font(.title)
            Text("Login")
              .fontWeight(.semibold)
              .font(.title)
              .frame(width: 200, height: 40)
          }
          .padding()
          .foregroundColor(.white)
          .background(Color.orange)
          .cornerRadius(10)
          
        }
        Image("testimage")

        Spacer()
        Button(action: {
          print("Signup tapped!")
        }) {
          HStack {
            Text("Not a member?")
              .fontWeight(.semibold)
              .underline()
              .font(.subheadline)
              .frame(width: 200, height: 40)
              .foregroundColor(.white)
          }
        }

      }//Vstack
    }//ZStack
  }//view
}

struct LoginView_Preview: PreviewProvider {
  static var previews: some View {
    LoginView()
  }
}
