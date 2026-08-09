//
//  SignInView.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 8/6/26.
//

import Foundation
import SwiftUI
import AuthenticationServices

struct SignInView: View {
    
    @Environment(AuthStore.self) private var authStore
    @State private var passkeyProvider: any PasskeySignInProviding = MockPasskeyCoordinator()
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            SignInWithAppleButton(.signIn) { request in
                
                request.requestedScopes = [.email]
                
            } onCompletion: { result in
                
                switch result {
                    
                case .success(let authorization):
                    
                    authStore.completeAppleSignIn(authorization)
                    
                case .failure(let error):
                    
                    authStore.handleAuthorizationError(error)
                    
                }
                
            }
            
            .signInWithAppleButtonStyle(.black)
            
            .frame(height: 44)
            
            Button("Sign in with a passkey") {
                
                passkeyProvider.signIn { result in
                    
                    switch result {
                        
                    case .success(let userID):
                        
                        authStore.completePasskeySignIn(userID: userID)
                        
                    case .failure(let error):
                        
                        authStore.handleAuthorizationError(error)
                        
                    }
                    
                }
                
            }
            
            #if DEBUG
            VStack(spacing: 8) {
                Button("Simulate Cancelled") { authStore.lastError = .cancelled }
                Button("Simulate Passkey Unavailable") { authStore.lastError = .passkeyUnavailable }
                Button("Simulate Hidden Email") { authStore.lastError = .hiddenAppleIDEmail }
            }
            .font(.caption)
            #endif
            
            if let lastError = authStore.lastError {
                
                VStack(spacing: 8) {
                    
                    Text(lastError.errorDescription ?? "Something went wrong.")
                    
                        .foregroundStyle(lastError.isBlocking ? .red : .secondary)
                    
                    Button("Try Again") {
                        
                        authStore.lastError = nil
                    }
                    
                }
                
                .padding()
                
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                
            }
            
        }
        
        .padding()
        
    }
    
}
