//
//  EditRecipePickerViewTableViewCell.swift
//  Recipe
//
//  Created by Shing Yien on 29/11/2020.
//

import UIKit

class EditRecipePickerViewTableViewCell: UITableViewCell, UITextFieldDelegate {
    
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
    
    // MARK: - Recipe Types Picker View Functions
    
    func setupPickerView(pickerController: PickerController, recipeTypes: [RecipeType]) {
        self.pickerController = pickerController
        self.recipeTypes = recipeTypes
        pickerController.commonInit(delegate: self, numOfRowsInComponent: recipeTypes.count, rowsData: recipeTypes, controlTextField: tfEditRecipe)
    }
    
    func showPickerView() {
        pickerController?.showPickerView()
    }
}

// MARK: - Extensions

extension EditRecipePickerViewTableViewCell: PickerDelegate {
    func didSelectRow(id: String) {
        if let index = recipeTypes?.firstIndex(where: {$0.id == id}) {
            tfEditRecipe.text = recipeTypes![index].name
        }
    }
}

