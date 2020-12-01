//
//  RecipeListPresenter.swift
//  Recipe
//
//  Created by Shing Yien on 28/11/2020.
//

import UIKit

protocol RecipeListDelegate: class {
    func showLoading()
    func hideLoading()
    func fetchDataFailed(message: String)
    func fetchRecipeTypesSucceed(data: [RecipeType])
    func fetchAllRecipesSucceed(data: [RecipeObject])
}

class RecipeListPresenter: DataServiceDelegate {

    func onRecipeTypesUpdated(recipeTypes: [RecipeType]) {
        fetchRecipeTypes()
    }
    
    weak var delegate: RecipeListDelegate?
    var dataService: DataService?
    var realmService: RealmService?
    
    init(delegate: RecipeListDelegate, dataService: DataService, realmService: RealmService ) {
        self.delegate = delegate
        self.dataService = dataService
        self.realmService = realmService
        
        dataService.addDelegate(delegate: self)
    }
    
    func fetchRecipeTypes() {
        if let recipeTypes = dataService?.getRecipeTypes() {
            self.delegate?.fetchRecipeTypesSucceed(data: recipeTypes)
        }
    }
    
    func fetchDefaultRecipes() {
        let defaultRecipes = (dataService?.getRecipes())!
        for recipe in defaultRecipes {
            let recipeToSave = Recipe (value: [
               "id": recipe.id,
               "name": recipe.name,
               "desc": recipe.description,
               "type": recipe.type,
               "typeId": recipe.typeId,
               "imageUrl": recipe.imageUrl,
               "ingredients": recipe.ingredients,
               "steps": recipe.steps,
               "createdDate": Date()
           ])
            realmService?.write(object: recipeToSave)
            
            if let allRecipes = realmService?.read(object: Recipe.self) {
                self.delegate?.hideLoading()
                self.delegate?.fetchAllRecipesSucceed(data: (Array(allRecipes)).map({($0 as! Recipe).managedObject()}))
            } else {
                self.delegate?.hideLoading()
            }
        }
    }
    
    func fetchAllRecipes() {
        self.delegate?.showLoading()
        
        if let allRecipes = realmService?.read(object: Recipe.self) {
            self.delegate?.hideLoading()
            self.delegate?.fetchAllRecipesSucceed(data: (Array(allRecipes)).map({($0 as! Recipe).managedObject()}))
        } else {
            self.delegate?.hideLoading()
        }
    }
}
