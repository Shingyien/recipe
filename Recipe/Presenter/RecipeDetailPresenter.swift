//
//  RecipeDetailPresenter.swift
//  Recipe
//
//  Created by Shing Yien on 30/11/2020.
//

import UIKit

protocol RecipeDetailDelegate: class {
    func showLoading()
    func hideLoading()
    func deleteRecipeFailed(message: String)
    func deleteRecipeSucceed()
    func updateImage(image: UIImage)
    func fetchRecipeSucceed(data: RecipeObject)
}

class RecipeDetailPresenter {

    weak var delegate: RecipeDetailDelegate?
    var realmService: RealmService?
    
    init(delegate: RecipeDetailDelegate, realmService: RealmService ) {
        self.delegate = delegate
        self.realmService = realmService
    }
    
    func fetchRecipe(id: String) {
        self.delegate?.showLoading()
        if let recipe = realmService?.read(object: Recipe.self)?.filter("id = '\(id)'").first {
            self.delegate?.hideLoading()
            self.delegate?.fetchRecipeSucceed(data: (recipe as! Recipe).managedObject())
        }
    }
    
    func deleteRecipe(id: String, imageUrl: String) {
        if let recipe = realmService?.read(object: Recipe.self)?.filter("id = '\(id)'").first {
            realmService?.delete(object: recipe)
            _ = ImageStore.removeImage(imageName: imageUrl)
            self.delegate?.deleteRecipeSucceed()
        } else {
            self.delegate?.deleteRecipeFailed(message: "Recipe does not exist")
        }
    }
    
    func getSavedImage(named: String) {
        if let image = ImageStore.retrieveImage(imageName: named) {
            self.delegate?.updateImage(image: image)
        }
    }
}
