//
//  SignInWithApple.swift
//  JustGroceries
//
//  Created by Paul Linck on 2/10/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import SwiftUI
import AuthenticationServices

// Subclass UIViewRepresentable when you need to wrap a UIView
final class SignInWithApple: UIViewRepresentable {
    // makeUIView should always return a specific type of UIView
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        // For now, I am not performing any customization,
        // so return the Sign In with Apple button object directly.
        return ASAuthorizationAppleIDButton()
    }
    
    // This is for customization
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
}

#if DEBUG
struct SignInWithApple_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithApple()
    }
}
#endif
