//
//  PickerView.swift
//  Recipe
//
//  Created by Shing Yien on 28/11/2020.
//

import UIKit

protocol PickerDelegate: NSObjectProtocol {
    func didSelectRow(id: String)
}

class PickerController: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var delegate: PickerDelegate?
    var pickerView: UIPickerView?
    var pickerViewTextField: UITextField?
        
    // MARK: - Properties
    var numOfRowsInComponent: Int = 0
    var rowsData: [RecipeType] = []
    
    func commonInit(delegate: PickerDelegate, numOfRowsInComponent: Int, rowsData: [RecipeType], controlTextField: UITextField) {
        pickerView = UIPickerView()
        pickerView?.dataSource = self
        pickerView?.delegate = self

        pickerViewTextField = controlTextField
        pickerViewTextField?.inputView = pickerView
        
        // Add Toolbar for picker
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.systemBlue
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.dismissPickerView))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        controlTextField.inputAccessoryView = toolBar
        
        self.delegate = delegate
        self.numOfRowsInComponent = numOfRowsInComponent
        self.rowsData = rowsData
    }
    
    func showPickerView() {
        pickerViewTextField?.becomeFirstResponder()
    }
    
    func updateData(data: [RecipeType])
    {
        numOfRowsInComponent = data.count
        rowsData = data
        pickerView?.reloadAllComponents()
    }
    
    // MARK: - Picker View delegate methods
    
    @objc func dismissPickerView() {
        pickerViewTextField?.resignFirstResponder()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numOfRowsInComponent
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.delegate?.didSelectRow(id: rowsData[row].id)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rowsData[row].name
    }
}
