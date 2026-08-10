//
//  AuthStore.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 8/6/26.
//

import Foundation
import Observation
import AuthenticationServices
enum AuthState: Equatable {
    
    case signedOut
    
    case signedIn(userID: String)
    
}

@Observable
final class AuthStore {
    
    private(set) var state: AuthState = .signedOut
    var lastError: AuthError?
    var hasStoredSession: Bool {
        
        TokenVault.read() != nil
    }
    
    func completeAppleSignIn(_ authorization: ASAuthorization) {
        
        lastError = nil
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            
            lastError = .unknown
            return
        }
        
        if let email = credential.email, email.hasSuffix("privaterelay.appleid.com") {
            
            lastError = .hiddenAppleIDEmail
        }
        
        establishSession(for: credential.user)
        
    }
    
    func handleAuthorizationError(_ error: Error) {
        
        switch (error as? ASAuthorizationError)?.code {
            
        case .canceled:
            
            lastError = .cancelled
        case .some(.notHandled), .some(.failed):
            
            lastError = .passkeyUnavailable
        default:
            
            lastError = .unknown
        }
        
    }
    
    func signOut() {
        
        TokenVault.delete()
        
        state = .signedOut
        lastError = nil
    }
    
    func completePasskeySignIn(userID: String) {
        
        lastError = nil
        establishSession(for: userID)
        
    }
    
    func establishSession(for userID: String) {
        
        let token = "st_" + UUID().uuidString
        guard TokenVault.save(token) else {
            
            lastError = .unknown
            return
        }
        
        state = .signedIn(userID: userID)
    }
}

