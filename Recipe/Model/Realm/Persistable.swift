//
//  Persistable.swift
//  Recipe
//
//  Created by Shing Yien on 30/11/2020.
//

import RealmSwift

public protocol Persistable {
    associatedtype ManagedObject: RealmSwift.Object
    init(managedObject: ManagedObject)
    func managedObject() -> ManagedObject
}
