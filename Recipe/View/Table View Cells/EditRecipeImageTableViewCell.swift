//
//  RecipeListImageTableViewCell.swift
//  Recipe
//
//  Created by Shing Yien on 30/11/2020.
//

import UIKit

protocol EditRecipeImageTableViewCellDelegate {
    func onBtnAddImageClicked()
}
class EditRecipeImageTableViewCell: UITableViewCell {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var ivRecipeImage: UIImageView!
    @IBOutlet weak var btnAddImage: UIButton!
    
    // MARK: - Properties
    
    var delegate: EditRecipeImageTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - IB Actions
    
    @IBAction func btnAddImageOnClick(_ sender: Any) {
        self.delegate?.onBtnAddImageClicked()
    }
}
