//
//  SignUp.swift
//  JustGroceries
//
//  Created by Paul Linck on 2/8/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import SwiftUI

struct SignUp: View {
    //MARK: Properties
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    
    @EnvironmentObject var session: FirebaseSession
    let labels = ["Email", "Password"]
    
    var body: some View {
        VStack {
            Text("Sign Uo")
                .font(.subheadline)
            
            Group {
                HStack {
                    VStack(alignment: .trailing) {
                        Text("First Name")
                            .frame(maxHeight: .infinity)
                            .padding(.bottom, 4)
                        Text("Last Name")
                            .frame(maxHeight: .infinity)
                            .padding(.bottom, 4)
                        Text("Email")
                            .frame(maxHeight: .infinity)
                            .padding(.bottom, 4)
                        Text("Password")
                            .frame(maxHeight: .infinity)
                            .padding(.bottom, 4)
                    }
                    
                    VStack {
                        TextField("FirstName", text: $firstName)
                            .font(.subheadline)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("LastName", text: $lastName)
                            .font(.subheadline)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
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
            
            Button(action: signUp) {
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
    // Signup
    // Note: if signup is successful, add it to firebase realtime DB
    func signUp() {
        if !email.isEmpty && !password.isEmpty && !firstName.isEmpty && !lastName.isEmpty {
            session.signUp(email: self.email,
                           password: self.password,
                           firstName: self.firstName,
                           lastName: self.lastName) { (result, error) in
                if error != nil {
                    print("Error signing up: \(error?.localizedDescription ?? "")")
                } else {
                    // Save to firebase realtime DB
                    if let user = result?.user {
                        let user = User(uid: user.uid, email: user.email!,
                                        firstName: self.firstName, lastName: self.lastName)
    
                        self.session.createUserInFirestore(user: user, onlineStatus: true)
                    }
                    
                    // Clear the form fields
                    self.email = ""
                    self.password = ""
                    self.firstName = ""
                    self.lastName = ""
                }
            }
        } else {
            print("Validation error on form")
        }
    }
}

#if DEBUG
struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp()
    }
}
#endif
