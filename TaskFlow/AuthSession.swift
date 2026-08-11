//
//  AuthSession.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 8/10/26.
//

import Foundation
struct AuthSession: Codable {
    
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    var isExpiringSoon: Bool {
        
        expiresAt <= .now.addingTimeInterval(30)
        
    }
    
}

extension AuthSession: CustomStringConvertible {
    
    var description: String {
        
        "AuthSession(expiresAt: (expiresAt))"
        
    }
    
}
