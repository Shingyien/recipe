//
//  RecipeListTableViewCell.swift
//  Recipe
//
//  Created by Shing Yien on 28/11/2020.
//

import UIKit
import Kingfisher

class RecipeListTableViewCell: UITableViewCell {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var recipeType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Configuration
    
    func commonInit(recipe: RecipeObject) {
        
        recipeTitle.text = recipe.name
        recipeType.text = recipe.type
        
        if recipe.imageUrl.contains("http"), let url = URL(string: recipe.imageUrl) {
            recipeImage.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        } else {
            recipeImage.image = getSavedImage(named: recipe.imageUrl)
        }
    }
    
    // MARK: - Functions
    
    func getSavedImage(named: String) -> UIImage? {
        return ImageStore.retrieveImage(imageName: named)
    }
}
