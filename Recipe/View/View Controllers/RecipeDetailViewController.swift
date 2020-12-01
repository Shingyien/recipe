//
//  RecipeDetailViewController.swift
//  Recipe
//
//  Created by Shing Yien on 28/11/2020.
//

import UIKit
import Kingfisher
import RealmSwift

class RecipeDetailViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var ivRecipePhoto: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblIngredients: UILabel!
    @IBOutlet weak var lblSteps: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblDescriptionHeader: UILabel!
    @IBOutlet weak var lblStepsHeader: UILabel!
    
    // MARK: - Properties
    
    var presenter: RecipeDetailPresenter?
    var id = ""
    var recipe: RecipeObject?
    var recipeTypes: [RecipeType] = []
    let refreshControl = UIRefreshControl()
    
    // Realm Token
    var notificationToken: NotificationToken? = nil
    
    // MARK: - From storyboard
    
    class func fromStoryboard() -> (UINavigationController, RecipeDetailViewController) {
        let navigationController = Storyboards.RecipeDetail.initialScene.instantiate()
        let viewController = navigationController.topViewController as! RecipeDetailViewController
        return (navigationController, viewController)
    }
    
    // MARK: - IB Actions
    
    @IBAction func btnEditRecipeOnClick(_ sender: Any) {
        editRecipe()
    }
    
    @IBAction func btnDeleteRecipeOnClick(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this recipe?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {_ in
            self.deleteRecipe()
        }))
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - View Controller Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = RecipeDetailPresenter(delegate: self, realmService: RealmService())
        
        // Setup
        setupRealmNotification()
        
        fetchRecipe()
        
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    // MARK: - Setup
    
    func setupRealmNotification() {
        if let results = RealmService.shared.read(object: Recipe.self)?.filter("id = '\(id)'") {
            
            notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
                
                self?.recipe = (Array(results)).map({($0 as! Recipe).managedObject()}).first
                
                switch changes {
                case .initial:
                    // Results are now populated and can be accessed without blocking the UI
                    self?.updateRecipe()
                case .update(_, _, _, _):
                    // Query results have changed, so apply them to the UITableView
                    self?.updateRecipe()
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                }
                
            }
        }
    }
    
    // MARK: - Internal functions
    
    private func fetchRecipe() {
        presenter?.fetchRecipe(id: id)
    }
    
    private func updateRecipe() {
        
        guard recipe != nil else {
            return
        }
        
        DispatchQueue.main.async {
            self.lblName.text = self.recipe?.name
            self.lblDesc.text = self.recipe?.description
            self.lblIngredients.text = self.recipe?.ingredients.joined(separator: "\n")
            
            var updatedSteps = ""
            var count = 1
            for step in self.recipe!.steps {
                if count != 1 {
                    updatedSteps.append("\n\n")
                }
                updatedSteps.append("\(count). ")
                updatedSteps.append(step)
                count += 1
            }
            self.lblSteps.text = updatedSteps
            
            if self.recipe!.imageUrl.contains("http"), let url = URL(string: self.recipe!.imageUrl) {
                self.ivRecipePhoto.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            } else {
                self.presenter?.getSavedImage(named: self.recipe!.imageUrl)
            }
        }
    }
    
    private func editRecipe() {
        guard let recipe = recipe else {
            return
        }
        
        let (navigationController, editRecipeViewController) = EditRecipeViewController.fromStoryboard()
        editRecipeViewController.id = recipe.id
        editRecipeViewController.name = recipe.name
        editRecipeViewController.type = recipe.type
        editRecipeViewController.typeId = recipe.typeId
        editRecipeViewController.imageUrl = recipe.imageUrl
        editRecipeViewController.desc = recipe.description
        editRecipeViewController.ingredients = recipe.ingredients
        editRecipeViewController.steps = recipe.steps
        editRecipeViewController.recipeTypes = recipeTypes
        editRecipeViewController.createdDate = recipe.createdDate
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    private func deleteRecipe() {
        presenter?.deleteRecipe(id: id, imageUrl: recipe?.imageUrl ?? "")
    }
}

// MARK: - Extensions

extension RecipeDetailViewController: RecipeDetailDelegate {
    func showLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.lblDescriptionHeader.isHidden = false
            self.lblStepsHeader.isHidden = false
            
            self.activityIndicator.stopAnimating()
        }
    }
    
    func fetchRecipeSucceed(data: RecipeObject) {
        recipe = data
        updateRecipe()
    }
    
    func deleteRecipeFailed(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func deleteRecipeSucceed() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func updateImage(image: UIImage) {
        self.ivRecipePhoto.image = image
    }
}

