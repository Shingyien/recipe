//
//  EditRecipeViewController.swift
//  Recipe
//
//  Created by Shing Yien on 29/11/2020.
//

import UIKit

enum EditRecipeSections: CaseIterable {
    case name, type, description, ingredients, steps, image
    
    static func numberOfSections() -> Int {
        return self.allCases.count
    }
    
    static func getSection(_ section: Int) -> EditRecipeSections {
        return self.allCases[section]
    }
}

class EditRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var editRecipeTableView: UITableView!
    @IBOutlet weak var btnSaveRecipe: UIButton!
    
    // MARK: - Properties
    
    let pickerController = PickerController()
    var presenter: EditRecipePresenter?
    var recipeTypes: [RecipeType] = []
    var pickerViewTextField: UITextField?
    var activeTextField: UITextField?
    
    var id = ""
    var name = ""
    var type = ""
    var typeId = ""
    var imageUrl = ""
    var desc = ""
    var ingredients: [String] = [""]
    var steps: [String] = [""]
    var image: UIImage?
    var createdDate: Date?
    var recipe: RecipeObject?
    
    // MARK: - IB Actions
    @IBAction func btnSaveRecipeOnClick(_ sender: Any) {
        saveRecipe()
    }
    
    // MARK: - From storyboard
    
    class func fromStoryboard() -> (UINavigationController, EditRecipeViewController) {
        let navigationController = Storyboards.EditRecipe.initialScene.instantiate()
        let viewController = navigationController.topViewController as! EditRecipeViewController
        return (navigationController, viewController)
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell xib
        editRecipeTableView.register( UINib(nibName: "EditRecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "EditRecipeTableViewCell")
        editRecipeTableView.register( UINib(nibName: "EditRecipeImageTableViewCell", bundle: nil), forCellReuseIdentifier: "EditRecipeImageTableViewCell")
        editRecipeTableView.register( UINib(nibName: "EditRecipePickerViewTableViewCell", bundle: nil), forCellReuseIdentifier: "EditRecipePickerViewTableViewCell")
        
        presenter = EditRecipePresenter(delegate: self, realmService: RealmService.shared)
        
        setupKeyboard()
        
        // Init recipe object
        recipe = RecipeObject(
            id: id,
            name: name,
            description: desc,
            type: type,
            typeId: typeId,
            imageUrl: imageUrl,
            ingredients: ingredients,
            steps: steps,
            createdDate: createdDate
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
    }
    
    // MARK: - Table view data source and delegate functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard recipe != nil else {
            return 0
        }
        
        switch EditRecipeSections.getSection(section) {
        case .ingredients:
            return recipe!.ingredients.count
        case .steps:
            return recipe!.steps.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch EditRecipeSections.getSection(section) {
        case .name:
            return "Name"
        case .type:
            return "Type"
        case .description:
            return "Description"
        case .ingredients:
            return "Ingredients"
        case .steps:
            return "Steps"
        default:
            return "Image"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard recipe != nil else {
            return UITableViewCell()
        }
        
        switch EditRecipeSections.getSection(indexPath.section) {
        
        case .image:
            let cell = editRecipeTableView.dequeueReusableCell(withIdentifier: "EditRecipeImageTableViewCell", for: indexPath) as! EditRecipeImageTableViewCell
            cell.delegate = self
            
            if imageUrl.contains("http"), let url = URL(string: imageUrl) {
                cell.ivRecipeImage.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            } else if !imageUrl.isEmpty {
                cell.ivRecipeImage.image = presenter?.getSavedImage(named: imageUrl)
            } else if let image = image {
                cell.ivRecipeImage.image = image
            }
            
            return cell
        case .type :
            let cell = editRecipeTableView.dequeueReusableCell(withIdentifier: "EditRecipePickerViewTableViewCell", for: indexPath) as! EditRecipePickerViewTableViewCell
            cell.commonInit(content: recipe!.type)
            cell.setupPickerView(pickerController: pickerController, recipeTypes: recipeTypes)
            
            cell.currentIndexPath = indexPath
            cell.delegate = self
            
            return cell
        default:
            let cell = editRecipeTableView.dequeueReusableCell(withIdentifier: "EditRecipeTableViewCell", for: indexPath) as! EditRecipeTableViewCell
            let section = EditRecipeSections.getSection(indexPath.section)
            
            if section == .name {
                cell.commonInit(content: recipe!.name)
            } else if section == .description {
                cell.commonInit(content: recipe!.description)
            } else if section == .ingredients {
                cell.commonInit(content: recipe!.ingredients[indexPath.row])
            } else if section == .steps {
                cell.commonInit(content: recipe!.steps[indexPath.row])
            }
            
            cell.currentIndexPath = indexPath
            cell.delegate = self
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard EditRecipeSections.getSection(section) == .ingredients || EditRecipeSections.getSection(section) == .steps else {
            return nil
        }
        
        var buttonTitle = ""
        let buttonTag = section
        
        if EditRecipeSections.getSection(section) == .ingredients {
            buttonTitle = "+ ingredient"
        } else if EditRecipeSections.getSection(section) == .steps {
            buttonTitle = "+ steps"
        }
        
        let footerView = UIView(frame: CGRect(x: 0,y: 0,width: self.view.bounds.width, height: 50))
        
        let actionButton = UIButton(type: .custom)
        actionButton.tag = buttonTag
        actionButton.setTitle(buttonTitle, for: .normal)
        actionButton.addTarget(self, action: #selector(addRow(_:)), for: .touchUpInside)
        actionButton.setTitleColor(UIColor.systemBlue, for: .normal)
        actionButton.contentHorizontalAlignment = .center
        actionButton.titleLabel?.lineBreakMode = .byCharWrapping
        actionButton.titleLabel?.baselineAdjustment = .alignCenters
        actionButton.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width/3, height: 40)
        actionButton.center = footerView.center
        
        footerView.addSubview(actionButton)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    @objc func addRow(_ sender: UIButton) {
        
        guard recipe != nil else {
            return
        }
        
        let section = EditRecipeSections.getSection(sender.tag)
        
        var lastRow = 0
        if section == .ingredients {
            recipe!.ingredients.append("")
            lastRow = recipe!.ingredients.count - 1
        } else if section == .steps {
            recipe!.steps.append("")
            lastRow = recipe!.steps.count - 1
        }
        
        let indexPath = IndexPath(row: lastRow, section: sender.tag)
        editRecipeTableView.beginUpdates()
        editRecipeTableView.insertRows(at: [indexPath], with: .automatic)
        editRecipeTableView.endUpdates()
        
        (editRecipeTableView.cellForRow(at: IndexPath(row: lastRow, section: sender.tag)) as? EditRecipeTableViewCell)?.tfEditRecipe.becomeFirstResponder()
    }
    
    // Mark: - Keyboard Notifications
    
    @objc func keyboardWillShowNotification(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        var shouldMoveViewUp = false
        
        if let activeTextField = activeTextField {
            
            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
            let topOfKeyboard = self.view.frame.height - keyboardSize.height
            
            // move view up if the Textfield bottom is below the top of keyboard
            if bottomOfTextField > topOfKeyboard {
                shouldMoveViewUp = true
            }
        }
        
        if(shouldMoveViewUp) {
            self.view.frame.origin.y = 0 - keyboardSize.height
        }
    }
    
    @objc func keyboardWillHideNotification(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // MARK: - Internal functions
    
    private func saveRecipe() {
        view.endEditing(true)
        
        if recipe != nil {
            
            // Create new id if it's new recipe
            if recipe!.id.isEmpty {
                recipe!.id = UUID().uuidString
            }
            
            // Update typeId
            if let index = recipeTypes.firstIndex(where: {$0.name == recipe?.type}) {
                recipe?.typeId = recipeTypes[index].id
            }
            
            if let image = image {
                presenter?.saveRecipeImage(image: image, imageName: recipe!.id)
            } else {
                saveRecipeToRealm()
            }
        }
    }
}

// MARK: - Extensions

extension EditRecipeViewController: EditRecipeDelegate {    
    func saveRecipeFailed(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func saveRecipeSucceed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveRecipeImageSucceed(imageUrl: String) {
        recipe!.imageUrl = imageUrl
        
        saveRecipeToRealm()
    }
    
    func saveRecipeToRealm() {
        recipe!.ingredients = recipe!.ingredients.filter({!$0.isEmpty})
        recipe!.steps = recipe!.steps.filter({!$0.isEmpty})
        
        let recipeToSave = Recipe (value: [
            "id": recipe!.id,
            "name": recipe!.name,
            "desc": recipe!.description,
            "type": recipe!.type,
            "typeId": recipe!.typeId,
            "imageUrl": recipe!.imageUrl,
            "ingredients": recipe!.ingredients,
            "steps": recipe!.steps,
            "createdDate": recipe!.createdDate ?? Date()
        ])
        
        presenter?.saveRecipe(recipe: recipeToSave)
    }
}

extension EditRecipeViewController: EditRecipeTableViewCellDelegate {
    func onTextFieldDidBeginEditing(activeTextField: UITextField) {
        self.activeTextField = activeTextField
    }
    
    func onTextChanged(indexPath: IndexPath, latestText: String) {
        switch EditRecipeSections.getSection(indexPath.section) {
        case .name:
            recipe?.name = latestText
        case .type:
            recipe?.type = latestText
        case .description:
            recipe?.description = latestText
        case .ingredients:
            recipe?.ingredients[indexPath.row] = latestText
        case .steps:
            recipe?.steps[indexPath.row] = latestText
        default:
            recipe?.name = latestText
        }
    }
}

extension EditRecipeViewController: EditRecipeImageTableViewCellDelegate {
    func onBtnAddImageClicked() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Recipe Image", message: "Choose an image for your recipe", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension EditRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        imageUrl = ""
        
        editRecipeTableView.reloadRows(at: [IndexPath(row: 0, section: 5)], with: .automatic)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
