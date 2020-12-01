//
//  DataService.swift
//  Recipe
//
//  Created by Shing Yien on 29/11/2020.
//

import Foundation

protocol DataServiceDelegate: AnyObject {
    func onRecipeTypesUpdated(recipeTypes: [RecipeType])
}

class DataService {
    // MARK: - Properties
    static let shared = DataService()
    var recipeTypeCollection: RecipeTypeCollection?
    var delegates: [DataServiceDelegate] = []
    
    // MARK: - Initialization
    init() {
        let storageAdapter: StorageAdapter = FirebaseStorageAdapter()
        storageAdapter.getXMLFile(filename: "recipetype.xml") { (data) in
            let xmlParser = CustomXMLParser()
            xmlParser.parseXML(data: data, dataParser: RecipeTypeCollection()) { (recipeTypeCollection) in
                print("RecipeTypeCollections \(recipeTypeCollection)")
                
                self.recipeTypeCollection = recipeTypeCollection as? RecipeTypeCollection
                self.informDelegates(recipeTypes: (recipeTypeCollection as! RecipeTypeCollection).recipeTypes)
            }
        }
    }
    
    // MARK: - Delegate functions
    func addDelegate(delegate: DataServiceDelegate) {
        if !delegates.contains(where: { $0 === delegate }) {
            delegates.append(delegate)
        }
    }
    
    func removeDelegate(delegate: DataServiceDelegate) {
        self.delegates.removeAll(where: {$0 === delegate} )
    }
    
    private func informDelegates(recipeTypes: [RecipeType]) {
        for delegate in delegates {
            delegate.onRecipeTypesUpdated(recipeTypes: recipeTypes)
        }
    }
    
    func getRecipeTypes() -> [RecipeType] {
        return recipeTypeCollection?.recipeTypes ?? []
    }
    
    func getRecipes() -> [RecipeObject]? {
        if let url = Bundle.main.url(forResource: "recipe", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                var jsonData = try decoder.decode(ResponseData.self, from: data)
                
                jsonData.recipes = jsonData.recipes.map({ (recipeObject) -> RecipeObject in
                    var newRecipeObject: RecipeObject = recipeObject
                    newRecipeObject.createdDate = Date()
                    return newRecipeObject
                })
                return jsonData.recipes
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
}

struct ResponseData: Decodable {
    var recipes: [RecipeObject]
}
