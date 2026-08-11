//
//  MockAuthBackend.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 8/10/26.
//

import Foundation
actor MockAuthBackend {
    func issueSession(for userID: String) async -> AuthSession {
        try? await Task.sleep(for: .seconds(1))
        return AuthSession(
            accessToken: "at_" + UUID().uuidString,
            refreshToken: "rt_" + UUID().uuidString,
            expiresAt: .now.addingTimeInterval(60)
        )
    }
 
    func refresh(refreshToken: String) async -> AuthSession {
        try? await Task.sleep(for: .seconds(1))
        return AuthSession(
            accessToken: "at_" + UUID().uuidString,
            refreshToken: refreshToken,
            expiresAt: .now.addingTimeInterval(60)
        )
    }
}
