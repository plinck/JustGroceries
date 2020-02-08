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
    let labels = ["Email", "Password"]
    
    
    var body: some View {
        VStack {
            Text("Sign In")
                .font(.subheadline)

            Group {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Email:")
                            .frame(maxHeight: .infinity)
                            .padding(.bottom, 4)
                        Text("Password:")
                            .frame(maxHeight: .infinity)
                            .padding(.bottom, 4)
                    }
                    
                    VStack {
                        TextField("nobody@email.com", text: $email)
                            .font(.subheadline)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        SecureField("password", text: $password)
                            .font(.subheadline)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.leading)
                }
                .padding()
                .fixedSize(horizontal: false, vertical: true)
            }
            
            Button(action: logIn) {
                Text("Sign In").bold().foregroundColor(.yellow)
            }
            .padding()
            .background(/*@START_MENU_TOKEN@*/Color.green/*@END_MENU_TOKEN@*/)
            .cornerRadius(/*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                        
            //.padding()
            Spacer()
            NavigationLink(destination: SignUp()) {
                Text("Don't have a login? Click to Sign Up").italic()
            }
        }
    }
    
    //MARK: Functions
    func logIn() {
        session.logIn(email: email, password: password) { (result, error) in
            if error != nil {
                print("Error Loggin In, Error \(String(describing: error))")
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
