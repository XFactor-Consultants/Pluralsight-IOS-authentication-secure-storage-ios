import Foundation
import Security
struct SessionVault {
    
    private static let service = "com.xfactorconsulting.TaskFlow"
    
    private static let account = "auth-session"
    
    static func save(_ session: AuthSession) -> Bool {
        
        guard let data = try? JSONEncoder().encode(session) else { return false }
        
        let query: [String: Any] = [
            
            kSecClass as String: kSecClassGenericPassword,
            
            kSecAttrService as String: service,
            
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(query as CFDictionary)
        
        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        return SecItemAdd(addQuery as CFDictionary, nil) == errSecSuccess
    }
    
    static func read() -> AuthSession? {
        
        let query: [String: Any] = [
            
            kSecClass as String: kSecClassGenericPassword,
            
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            
            kSecReturnData as String: true,
            
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              
                let data = result as? Data else { return nil }
        
        return try? JSONDecoder().decode(AuthSession.self, from: data)
    }
    
    static func delete() {
        
        let query: [String: Any] = [
            
            kSecClass as String: kSecClassGenericPassword,
            
            kSecAttrService as String: service,
            
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(query as CFDictionary)
        
    }
}
