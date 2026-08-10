//
//  TokenVault.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 8/9/26.
//

import Foundation
import Security
struct TokenVault {
    
    private static let service = "com.xfactorconsulting.TaskFlow"
    
    private static let account = "session-token"
    
    static func save(_ token: String) -> Bool {
        let query: [String: Any] = [
            
            kSecClass as String: kSecClassGenericPassword,
            
            kSecAttrService as String: service,
            
            kSecAttrAccount as String: account,
            
            kSecValueData as String: Data(token.utf8),
            
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            
            return update(token)
            
        }
        
        return status == errSecSuccess
    }
    
    static func read() -> String? {
        
        let query: [String: Any] = [
            
            kSecClass as String: kSecClassGenericPassword,
            
            kSecAttrService as String: service,
            
            kSecAttrAccount as String: account,
            
            kSecReturnData as String: true,
            
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
    static func update(_ token: String) -> Bool {
        
        let query: [String: Any] = [
            
            kSecClass as String: kSecClassGenericPassword,
            
            kSecAttrService as String: service,
            
            kSecAttrAccount as String: account
        ]
        
        let changes: [String: Any] = [kSecValueData as String: Data(token.utf8)]
        
        return SecItemUpdate(query as CFDictionary, changes as CFDictionary) == errSecSuccess
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
