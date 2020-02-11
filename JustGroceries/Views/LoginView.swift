//
//  LoginView.swift
//  JustGroceries
//
//  Created by Paul Linck on 2/6/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import SwiftUI
import GoogleSignIn
import AuthenticationServices

struct LoginView: View {
    @Environment(\.window) var window: UIWindow?
    @State var appleSignInDelegates: SignInWithAppleDelegates! = nil

    //MARK: Properties
    @State var email: String = ""
    @State var password: String = ""
    
    @EnvironmentObject var session: FirebaseSession
    
    var body: some View {
        VStack {
            Text("Sign In")
                .font(.subheadline)

            Group {
                HStack {
                    VStack(alignment: .trailing) {
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
                    Image(systemName: "envelope").resizable().frame(width: 30, height: 30, alignment: .center)
                    Text("Sign In with email").bold()
                }.frame(width: 280, height: 60, alignment: .center)
            }
            .background(Color.white)
            .cornerRadius(4.0)
            .shadow(radius: 4.0)
                        
            SignInWithApple()
                .frame(width: 280, height: 60)
                .shadow(radius: 4.0)
                .onTapGesture(perform: loginApple)

            Button(action: logginGoogle, label: {
                HStack { Image("ic_google").renderingMode(.original).resizable().frame(width: 50, height: 50, alignment: .center)
                    Text("Signin with Google")
                }.frame(width: 280, height: 60, alignment: .center)
            })
            .background(Color.white)
            .cornerRadius(4.0)
            .shadow(radius: 4.0)
                                    
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
    
    // Apple Sign In
    private func loginApple() {
        // All sign in requests need an ASAuthorizationAppleIDRequest
        let request = ASAuthorizationAppleIDProvider().createRequest()
        let myNonce = Nonce()
        let rawNonce = myNonce.randomNonceString()
        let hashedNonce = myNonce.sha256(rawNonce)
        
        // These are the pieces of data I want returned from apple signin request
        request.requestedScopes = [.fullName, .email]
        request.nonce = hashedNonce

        // Generate the controller which will display the sign in dialog
        performAppleSignIn(using: [request], rawNonce: rawNonce, hashedNonce: hashedNonce)
    }
    
    // Perform the signin
    private func performAppleSignIn(using requests: [ASAuthorizationRequest], rawNonce: String?, hashedNonce: String?) {
        // Generate the delegate and assign it to the class’ property
    appleSignInDelegates = SignInWithAppleDelegates(window: window, rawNonce: rawNonce, hashedNonce: hashedNonce) { success in
            if success {
                print("appleSignInDelegates created successfully")
            } else {
                print("appleSignInDelegates unsuccessful")
            }
        }
        
        // Generate the ASAuthorizationController as before,
        // but this time, tell it to use custom delegate class
        let controller = ASAuthorizationController(authorizationRequests: requests)
        controller.delegate = appleSignInDelegates
        controller.presentationContextProvider = appleSignInDelegates
        
        // By calling performRequests(), you’re asking iOS
        // to display the Sign In with Apple modal view
        controller.performRequests()
    }
        
    /// Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
    private func performAppleExistingAccountSetupFlows() {
        #if !targetEnvironment(simulator)
        // Note that this won't do anything in the simulator.  You need to
        // be on a real device or you'll just get a failure from the call.
        let requests = [
            ASAuthorizationAppleIDProvider().createRequest(),
            ASAuthorizationPasswordProvider().createRequest()
        ]
        
        performAppleSignIn(using: requests, rawNonce: nil, hashedNonce: nil)
        #endif
    }
    
    // Google signin
    private func logginGoogle() {
        let socialLogin = SocialLogin()
        socialLogin.attemptLoginGoogle()
    }

    // Google or other social media signin
    private struct SocialLogin: UIViewRepresentable {
        
        func makeUIView(context: UIViewRepresentableContext<SocialLogin>) -> UIView {
            return UIView()
        }
        
        func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<SocialLogin>) {
        }
        
        func attemptLoginGoogle() {
            // MARK: - Fixed google not be able to login again after first attempt
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
