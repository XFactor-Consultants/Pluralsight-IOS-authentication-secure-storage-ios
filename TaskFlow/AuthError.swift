//
//  AuthError.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 8/9/26.
//

import Foundation
enum AuthError: LocalizedError, Equatable {
    case cancelled
    case passkeyUnavailable
    case hiddenAppleIDEmail
    case unknown
    
    var errorDescription: String? {
        
        switch self {
            
        case .cancelled: "Sign-in was cancelled."
            
        case .passkeyUnavailable: "No passkey was found for this account on this device."
            
        case .hiddenAppleIDEmail: "Apple hid your email. TaskFlow will use your private relay address."
            
        case .unknown: "Something went wrong while signing in. Please try again."
            
        }
        
    }
    
    var isBlocking: Bool {
        
        switch self {
            
        case .hiddenAppleIDEmail: false
        default: true
        }
    }
}
