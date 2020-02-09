//
//  LoginView.swift
//  JustGroceries
//
//  Created by Paul Linck on 2/6/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import SwiftUI
import GoogleSignIn

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
                HStack {
                    Image(systemName: "envelope").resizable().frame(width: 50, height: 50, alignment: .center)
                    Text("Sign In with email").bold().foregroundColor(.yellow)
                }.frame(width: 250, height: 60, alignment: .center)
            }
            .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(8.0)
            .shadow(radius: 4.0)
            
            Button(action: logIn) {
                HStack {
                    // Image(systemName: "heart.fill")
                    Image("ic_apple").renderingMode(.original).resizable().frame(width: 50, height: 50, alignment: .center)
                    Text("Sign In with apple ID")
                }.frame(width: 250, height: 60, alignment: .center)
            }
            .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(8.0)
            .shadow(radius: 4.0)


            Button(action: logginGoogle, label: {
                HStack { Image("ic_google").renderingMode(.original).resizable().frame(width: 50, height: 50, alignment: .center)
                    Text("Signin with Google")
                }.frame(width: 250, height: 60, alignment: .center)
            })
            .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(8.0)
            .shadow(radius: 4.0)
            
//            let button = GIDSignInButton()
//            button.colorScheme = .dark
                        
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
    
    // Google signin
    func logginGoogle() {
        let socialLogin = SocialLogin()
        socialLogin.attemptLoginGoogle()
    }
    
    // Google or other social media signin
    struct SocialLogin: UIViewRepresentable {
        
        func makeUIView(context: UIViewRepresentableContext<SocialLogin>) -> UIView {
            return UIView()
        }
        
        func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<SocialLogin>) {
        }
        
        func attemptLoginGoogle() {
            // MARK: - Fixed google not be able to login again afert first attempt
            // I replaced the line below to force the user to go back to content view
            // created vc from rootview controller which is contentView (hostted)
            // Then, set that as the view google goes back to after login
            // that view is smart enough to go to login if user is not authenticated.
            
            //GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.last?.rootViewController
            
            // New code to force google to go back to main page after login every time
            // it was erroting out after frst time.  hope this isnt a leak in memory
            let vc = UIApplication.shared.windows.first!.rootViewController
            GIDSignIn.sharedInstance()?.presentingViewController = vc
            // GIDSignIn.sharedInstance()?.presentingViewController = self
            GIDSignIn.sharedInstance()?.signIn()
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
