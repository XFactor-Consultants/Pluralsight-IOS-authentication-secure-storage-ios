import Foundation
import SwiftUI
@Observable
final class LocalContentCache {
    
    private struct Entry {
        
        let encrypted: Data
        let hash: String
        
    }
    
    private var storage: [UUID: Entry] = [:]
    
    func store(_ content: String, for taskID: UUID) {
        
        guard let encrypted = try? TaskEncryption.encrypt(content) else { return }
        
        storage[taskID] = Entry(encrypted: encrypted, hash: TaskEncryption.hash(content))
    }
    
    func content(for taskID: UUID) -> String? {
        
        guard let entry = storage[taskID],
              
                let decrypted = try? TaskEncryption.decrypt(entry.encrypted),
              
                TaskEncryption.hash(decrypted) == entry.hash else { return nil }
        
        return decrypted
    }
    
    func clear() {
        
        storage.removeAll()
        
    }
    
}

#if DEBUG

extension LocalContentCache {
    
    func debugCorruptFirstEntry() {
        
        guard let key = storage.keys.first, var entry = storage[key] else { return }
        
        entry = Entry(encrypted: entry.encrypted.dropLast() + Data([0]), hash: entry.hash)
        
        storage[key] = entry
        
    }
    
}

#endif

