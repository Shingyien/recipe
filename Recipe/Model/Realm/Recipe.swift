//
//  Recipe.swift
//  Recipe
//
//  Created by Shing Yien on 28/11/2020.
//

import RealmSwift

class Recipe: Object {
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var desc = ""
    @objc dynamic var type = ""
    @objc dynamic var typeId = ""
    @objc dynamic var imageUrl = ""
    var ingredients = List<String>()
    var steps = List<String>()
    @objc dynamic var createdDate = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Recipe {
    public func managedObject() -> RecipeObject {
        let recipe = RecipeObject (
            id: id,
            name: name,
            description: desc,
            type: type,
            typeId: typeId,
            imageUrl: imageUrl,
            ingredients: ingredients.map({ $0.self }),
            steps: steps.map({ $0.self }),
            createdDate: createdDate
        )
        
        return recipe
    }
}
