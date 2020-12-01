//
//  RecipeObject.swift
//  Recipe
//
//  Created by Shing Yien on 29/11/2020.
//

import Foundation

struct RecipeObject: Decodable {
    public var id: String
    public var name: String
    public var description: String
    public var type: String
    public var typeId: String
    public var imageUrl: String
    public var ingredients: [String]
    public var steps: [String]
    public var createdDate: Date?
}

extension RecipeObject: Persistable {
    public init(managedObject: Recipe) {
        id = managedObject.id
        name = managedObject.name
        description = managedObject.desc
        type = managedObject.type
        typeId = managedObject.typeId
        imageUrl = managedObject.imageUrl
        ingredients = managedObject.ingredients.map({ $0.self })
        steps = managedObject.steps.map({ $0.self })
        createdDate = managedObject.createdDate
    }
    
    public func managedObject() -> Recipe {
        let recipe = Recipe()
        
        recipe.id = id
        recipe.name = name
        recipe.desc = description
        recipe.type = type
        recipe.typeId = typeId
        recipe.imageUrl = imageUrl
        recipe.ingredients.append(objectsIn: ingredients)
        recipe.steps.append(objectsIn: steps)
        recipe.createdDate = createdDate!
    
        return recipe
    }
}

