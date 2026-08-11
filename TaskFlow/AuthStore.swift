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
    
    private let backend = MockAuthBackend()
    
    var hasStoredSession: Bool {
        
        SessionVault.read() != nil
        
    }
    let contentCache: LocalContentCache
    init(contentCache: LocalContentCache) {
        
        self.contentCache = contentCache
        
        if let session = SessionVault.read() {
            
            state = .signedIn(userID: "restored-session")
            
        }
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
        
        Task {
            
            await establishSession(for: credential.user)
            
        }
        
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
    
    func signOut() async {
        
        SessionVault.delete()
        
        contentCache.clear()
        
        state = .signedOut
        
        lastError = nil
    }
    
    func completePasskeySignIn(userID: String) {
        
        lastError = nil
        
        Task {
            
            await establishSession(for: userID)
            
        }
        
    }
    
    func establishSession(for userID: String) async {
        
        let session = await backend.issueSession(for: userID)
        
        guard SessionVault.save(session) else {
            
            lastError = .unknown
            return
        }
        
        state = .signedIn(userID: userID)
        
    }
    
    func refreshIfNeeded() async {
        
        guard let session = SessionVault.read(), session.isExpiringSoon else { return }

        let refreshed = await backend.refresh(refreshToken: session.refreshToken)

        if !SessionVault.save(refreshed) {
            
            lastError = .unknown
        }
    }
    
#if DEBUG
    func debugForceExpire() async {
        
        guard let session = SessionVault.read() else { return }
        
        let expired = AuthSession(
            
            accessToken: session.accessToken,
            
            refreshToken: session.refreshToken,
            
            expiresAt: .now.addingTimeInterval(-1)
            
        )
        
        _ = SessionVault.save(expired)
        
    }
    
#endif
}

