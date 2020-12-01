//
//  RealmService.swift
//  Recipe
//
//  Created by Shing Yien on 28/11/2020.
//

import Foundation
import RealmSwift

class RealmService {
    
    // MARK: - Properties
    static let shared = RealmService()
    var realm: Realm?
    
    // MARK: - Initialization
    init() {
        // Get the default Realm
        do {
            realm = try Realm(configuration: Security.securitySettings())
        } catch {
            print("Failed to get Realm")
        }
    }

    func read(object: Object.Type) -> Results<Object>? {
        if realm?.objects(object) != nil {
            return realm?.objects(object)
        }
        
        return nil
    }
    
    // MARK: - Delegate functions
    func write(object: Object) -> Bool {
        do {
            try realm?.write {
                realm?.add(object, update: .modified)
            }
            return true
        } catch {
            //handle error
            return false
        }
    }
    
    func delete(object: Object) {
        realm?.writeAsync(obj: object) { (realm, obj) in
            realm.delete(obj!)
        }
    }
}

extension Realm {
    func writeAsync<T : ThreadConfined>(obj: T, errorHandler: @escaping ((_ error : Swift.Error) -> Void) = { _ in return }, block: @escaping ((Realm, T?) -> Void)) {
        let wrappedObj = ThreadSafeReference(to: obj)
        DispatchQueue(label: "background").async {
            autoreleasepool {
                do {
                    let realm = try Realm(configuration: Security.securitySettings())
                    let obj = realm.resolve(wrappedObj)

                    try realm.write {
                        block(realm, obj)
                    }
                }
                catch {
                    errorHandler(error)
                }
            }
        }
    }
}

