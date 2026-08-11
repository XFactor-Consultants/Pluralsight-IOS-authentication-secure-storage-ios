//
//  TaskEncryption.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 8/11/26.
//

import Foundation
import CryptoKit
enum TaskEncryption {
    
    static func hash(_ content: String) -> String {
        
        SHA256.hash(data: Data(content.utf8)).map { String(format: "%02x", $0) }.joined()
        
    }
    
    static func encrypt(_ content: String) throws -> Data {
        
        try AES.GCM.seal(Data(content.utf8), using: CryptoKeyStore.key()).combined!
        
    }
    
    static func decrypt(_ data: Data) throws -> String {
        
        let box = try AES.GCM.SealedBox(combined: data)
        
        let decrypted = try AES.GCM.open(box, using: CryptoKeyStore.key())
        
        return String(data: decrypted, encoding: .utf8) ?? ""
        
    }
    
}

