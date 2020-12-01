//
//  EditRecipePresenter.swift
//  Recipe
//
//  Created by Shing Yien on 29/11/2020.
//

import UIKit

protocol EditRecipeDelegate: class {
    func saveRecipeFailed(message: String)
    func saveRecipeSucceed()
    func saveRecipeImageSucceed(imageUrl: String)
}

class EditRecipePresenter {
    
    weak var delegate: EditRecipeDelegate?
    var realmService: RealmService?
    
    init(delegate: EditRecipeDelegate, realmService: RealmService ) {
        self.delegate = delegate
        self.realmService = realmService
    }
    
    func saveRecipe(recipe: Recipe) {
        guard let realmService = realmService else {
            return
        }
        
        if realmService.write(object: recipe) {
            self.delegate?.saveRecipeSucceed()
        } else {
            self.delegate?.saveRecipeFailed(message: "Failed to save recipe. Please try again later.")
        }
    }
    
    func saveRecipeImage(image: UIImage, imageName: String) {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return
        }
        do {
            try data.write(to: directory.appendingPathComponent(imageName)!)
            self.delegate?.saveRecipeImageSucceed(imageUrl: imageName)
        } catch {
            print(error.localizedDescription)
            self.delegate?.saveRecipeFailed(message: "Failed to save recipe. Please try again later.")
        }
    }
    
    func getSavedImage(named: String) -> UIImage? {
        return ImageStore.retrieveImage(imageName: named)
    }
}

