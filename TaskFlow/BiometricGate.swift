//
//  BiometricGate.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 8/9/26.
//

import Foundation
import LocalAuthentication
@Observable
final class BiometricGate {
    
    private(set) var isUnlocked = false
    
    private(set) var unavailableMessage: String?
    
    func requestUnlock() async {
        
        let context = LAContext()
        
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            
            unavailableMessage = "Unlocking requires a device passcode to be set."
            
            return
            
        }
        
        do {
            
            isUnlocked = try await context.evaluatePolicy(
                
                .deviceOwnerAuthentication,
                
                localizedReason: "Unlock this sensitive task."
                
            )
            
        } catch {
            
            isUnlocked = false
        }
        
    }
    
}
