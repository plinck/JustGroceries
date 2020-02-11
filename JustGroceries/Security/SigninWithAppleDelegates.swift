//
//  SignInWithAppleDelegates.swift
//  JustGroceries
//
//  Created by Paul Linck on 2/10/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import UIKit
import AuthenticationServices
import Contacts

class SignInWithAppleDelegates: NSObject {
    private let signInSucceeded: (Bool) -> Void
    private weak var window: UIWindow!
    
    init(window: UIWindow?, onSignedIn: @escaping (Bool) -> Void) {
        self.window = window
        self.signInSucceeded = onSignedIn
    }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerDelegate {
    
    // Implement apple delegates for doing the auth
    // When authorization is successful, this will be called
    // ASAuthorization includes properties asked for(e.g email, name)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // By examining the credential property,
        // you determine whether the user authenticated via
        // Apple ID or a stored iCloud password.
        switch authorization.credential {
            case let appleIdCredential as ASAuthorizationAppleIDCredential:
                // If you receive details, you know it’s a new registration
                if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
                    // Call your registration method
                    registerNewAccount(credential: appleIdCredential)
                } else {
                    // Call your existing account method if you don’t receive details
                    signInWithExistingAccount(credential: appleIdCredential)
                }
                break
            
            case let passwordCredential as ASPasswordCredential:
                // When using Sign In with Apple, the end user could select credentials
                // which are already stored in the iCloud keychain for the site
                signInWithUserAndPassword(credential: passwordCredential)
                break
            
            default:
                break
        }
    }
    
    // When authorization is unsuccessful, this will be called
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error in Apple authorizationController \(error.localizedDescription)")
    }
    
    // Register New Account and store in Apple Keychain - I
    // believe I need to change this dramatically to deal with firebase instead
    private func registerNewAccount(credential: ASAuthorizationAppleIDCredential) {
        // Save the desired details and the Apple-provided user in a struct
        let userData = UserData(email: credential.email!,
                                name: credential.fullName!,
                                identifier: credential.user)
        
        // Store the details into the iCloud keychain for later use
        let keychain = UserDataKeychain()
        do {
            try keychain.store(userData)
        } catch {
            print("signIn Did NOT succeed in registerNewAccount")
            self.signInSucceeded(false)
        }
        
        // Make a call to your service and signify to the caller whether registration succeeded or not
        do {
            let success = try WebApi.Register(
                user: userData,
                identityToken: credential.identityToken,
                authorizationCode: credential.authorizationCode
            )
            print("signInSucceeded in registerNewAccount")
            self.signInSucceeded(success)
        } catch {
            print("signIn Did NOT succeed in registerNewAccount")
            self.signInSucceeded(false)
        }
    }
    
    // When an existing user logs into your app, Apple doesn’t provide the email and full name
    private func signInWithExistingAccount(credential: ASAuthorizationAppleIDCredential) {
        // You *should* have a fully registered account here.  If you get back an error
        // from your server that the account doesn't exist, you can look in the keychain
        // for the credentials and rerun setup
        
        // if (WebAPI.login(credential.user,
        //                  credential.identityToken,
        //                  credential.authorizationCode)) {
        //   ...
        // }
        
        print("signInSucceeded in signInWithExistingAccount")
        self.signInSucceeded(true)
    }
    
    private func signInWithUserAndPassword(credential: ASPasswordCredential) {
        // You *should* have a fully registered account here.  If you get back an error from your server
        // that the account doesn't exist, you can look in the keychain for the credentials and rerun setup
        
        // if (WebAPI.Login(credential.user, credential.password)) {
        //   ...
        // }
        print("signInSucceeded in signInWithUserAndPassword")
        self.signInSucceeded(true)
    }
}

extension SignInWithAppleDelegates:
ASAuthorizationControllerPresentationContextProviding {
    
    // The delegate implements that is expected to return the window,
    // which shows the Sign In with Apple modal dialog
    func presentationAnchor(for controller: ASAuthorizationController)
        -> ASPresentationAnchor {
            return self.window
    }
}
