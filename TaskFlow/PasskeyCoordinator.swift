//
//  PasskeyCoordinator.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 8/6/26.
//

import Foundation
protocol PasskeySignInProviding {
    
    func signIn(completion: @escaping (Result<String, Error>) -> Void)
    
}

#if DEBUG
/// Passkey resolution requires an associated domain owned by a real backend.
/// This mock simulates a resolved credential so sign-in flow can be built
/// and demoed without one. A shipping app swaps in a real
/// ASAuthorizationController-based implementation behind this same protocol.
final class MockPasskeyCoordinator: PasskeySignInProviding {
    func signIn(completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            completion(.success("mock-passkey-user-7F3A"))
        }
    }
}
#endif

