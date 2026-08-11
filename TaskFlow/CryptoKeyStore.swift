//
//  CryptoKeyStore.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 8/11/26.
//

import Foundation
import CryptoKit
import Security
struct CryptoKeyStore {
    
    private static let service = "com.xfactorconsulting.TaskFlow"
    
    private static let account = "content-encryption-key"
    
    static func key() -> SymmetricKey {
        
        let query: [String: Any] = [
            
            kSecClass as String: kSecClassGenericPassword,
            
            kSecAttrService as String: service,
            
            kSecAttrAccount as String: account,
            
            kSecReturnData as String: true,
            
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        
        if SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
           
            let data = result as? Data {
            
            return SymmetricKey(data: data)
            
        }
        
        let newKey = SymmetricKey(size: .bits256)
        
        let addQuery: [String: Any] = [
            
            kSecClass as String: kSecClassGenericPassword,
            
            kSecAttrService as String: service,
            
            kSecAttrAccount as String: account,
            
            kSecValueData as String: newKey.withUnsafeBytes { Data($0) },
            
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        SecItemAdd(addQuery as CFDictionary, nil)
        
        return newKey
        
    }
    
}

