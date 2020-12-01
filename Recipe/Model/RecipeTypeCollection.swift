//
//  RecipeTypeCollection.swift
//  Recipe
//
//  Created by Shing Yien on 28/11/2020.
//

import Foundation

class RecipeTypeCollection: XMLParsable {
    let supportedElementNames: [String] = ["type"]
    var recipeTypes: [RecipeType] = []
    
    func isSupported(elementName: String) -> Bool {
        return supportedElementNames.contains(elementName)
    }
    
    func parse(elementName: String, attributeDict: [String : String]) {
        if let id = attributeDict["id"], let name = attributeDict["name"] {
            recipeTypes.append(RecipeType(id: id, name: name))
        }
    }
    
    func parse(elementName: String, value: String) {
        // implement here if there's value for element
    }
}
