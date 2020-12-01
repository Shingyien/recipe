//
//  EditRecipeTableViewCell.swift
//  Recipe
//
//  Created by Shing Yien on 29/11/2020.
//

import UIKit

protocol EditRecipeTableViewCellDelegate {
    func onTextChanged(indexPath: IndexPath, latestText: String)
    func onTextFieldDidBeginEditing(activeTextField: UITextField)
}

class EditRecipeTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tfEditRecipe: UITextField!
    
    // MARK: - Properties
    
    var delegate: EditRecipeTableViewCellDelegate?
    var currentIndexPath: IndexPath?
    var pickerController: PickerController?
    var recipeTypes: [RecipeType]?
    var activeTextField: UITextField?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tfEditRecipe.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        if pickerController != nil {
            pickerController = nil
        }
    }
    
    // MARK: - Configurations
    
    func commonInit(content: String) {
        tfEditRecipe.text = content
    }
    
    // MARK: - Textfield delegate methods
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let delegate = self.delegate {
            delegate.onTextChanged(indexPath: self.currentIndexPath!, latestText: textField.text!)
        }
        activeTextField = nil
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.onTextFieldDidBeginEditing(activeTextField: textField)
    }
}
