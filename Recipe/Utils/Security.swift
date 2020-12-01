//
//  Security.swift
//  Recipe
//
//  Created by Shing Yien on 29/11/2020.
//

import KeychainSwift
import RealmSwift

class Security {
    
    // Keychain
    static let keychainId = "pa-realm-encryption"
    static let keychain = KeychainSwift()
    
    // For realm
    static let schemaVersion = 1
    
    private static func isAppAlreadyLaunchedOnce() -> Bool{
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce") {
            // App is launched previouslt
            return true
        } else {
            // App is launched for the first time
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            return false
        }
    }
    
    private static func createKeyValue() -> Data
    {
        var key = Data(count: 64)
        
        _ = key.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 64, $0.baseAddress!)
        }
        
        let keychain = KeychainSwift()
        keychain.set(key, forKey: Security.keychainId, withAccess: .accessibleAlways)
        
        return key
    }
    
    private static func getKeyValue() -> Data?
    {
        return keychain.getData(Security.keychainId)
    }
    
    static func securitySettings() -> Realm.Configuration
    {
        if(isAppAlreadyLaunchedOnce()) // not first time app launch
        {
            // load key value from keychain
            if let key = getKeyValue(){
                let config = Realm.Configuration(encryptionKey: key,
                                                 schemaVersion: UInt64(schemaVersion),
                                                 migrationBlock: { migration, oldSchemaVersion in
                                                    // We haven’t migrated anything yet, so oldSchemaVersion == 0
                                                    if (oldSchemaVersion < schemaVersion) {
                                                        // Nothing to do!
                                                        // Realm will automatically detect new properties and removed properties
                                                        // And will update the schema on disk automatically
                                                    }
                })
                return config
            }
        }
        
        // Create new encryption key
        let key = createKeyValue()
        
        let config = Realm.Configuration(encryptionKey: key,
                                         schemaVersion: UInt64(schemaVersion),
                                         migrationBlock: { migration, oldSchemaVersion in
                                            // We haven’t migrated anything yet, so oldSchemaVersion == 0
                                            if (oldSchemaVersion < schemaVersion) {
                                                // Nothing to do!
                                                // Realm will automatically detect new properties and removed properties
                                                // And will update the schema on disk automatically
                                            }
        })
        return config
        
    }
    
    // MARK: Check realm to make sure encryption key is valid
    static func checkRealm() {
        let configuration = Security.securitySettings()
        do {
            // Check if there is any issue with realm
            _ = try Realm(configuration: configuration)
        }
        catch {
            // Encryption key invalid. Delete old realm path so realm can be recreated
            try? FileManager().removeItem(at: configuration.fileURL!)
        }
    }
}
