//
//  HomeViewController.swift
//  Recipe
//
//  Created by Shing Yien on 28/11/2020.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // IB outlets
    
    @IBOutlet weak var recipeListTableView: UITableView!
    @IBOutlet weak var btnFilter: UIButton!
    
    // Constraints
    @IBOutlet weak var recipeTypePickerViewBottomConstraint: NSLayoutConstraint!
    
    // Presenter
    var presenter: RecipeListPresenter?
    
    // MARK: - Properties
    
    var allRecipes: [RecipeObject] = []
    var filteredRecipes: [RecipeObject] = []
    var recipeTypes: [RecipeType] = [RecipeType(id: "all", name: "All")]
    let refreshControl = UIRefreshControl()
    let pickerController = PickerController()
    
    // Realm Token
    var notificationToken: NotificationToken? = nil
    
    // MARK: - From storyboard
    
    class func fromStoryboard() -> (UINavigationController, HomeViewController) {
        let navigationController = Storyboards.Home.initialScene.instantiate()
        let viewController = navigationController.topViewController as! HomeViewController
        return (navigationController, viewController)
    }
    
    // MARK: - IB Actions
    
    @IBAction func btnFilterOnClick(_ sender: Any) {
        showPickerView()
    }
    
    @IBAction func btnAddRecipeOnClick(_ sender: Any) {
        let (navigationController, editRecipeViewController) = EditRecipeViewController.fromStoryboard()
        
        var recipeTypesWithoutAll = recipeTypes
        recipeTypesWithoutAll.remove(at: 0)
        editRecipeViewController.recipeTypes = recipeTypesWithoutAll
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - View Controller Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell xib
        recipeListTableView.register( UINib(nibName: "RecipeListTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeListTableViewCell")
        
        // Set dynamic height for cell
        recipeListTableView.rowHeight = UITableView.automaticDimension
        recipeListTableView.estimatedRowHeight = 200.0
        
        // Set presenter
        presenter = RecipeListPresenter(delegate: self, dataService: DataService.shared, realmService: RealmService.shared)
        
        fetchRecipeTypes()
        setupPickerView()
        
        // Add target for refresh control
        refreshControl.addTarget(self, action: #selector(self.refreshRecipeList(_:)), for: .valueChanged)
        
        // Setup realm notification
        setupRealmNotification()
    
        presenter?.fetchAllRecipes()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    // MARK: - Setup
    
    func setupRealmNotification() {
        if let results = RealmService.shared.read(object: Recipe.self) {

            notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
                guard (self?.recipeListTableView) != nil else { return }
                
                self?.filteredRecipes = (Array(results)).map({($0 as! Recipe).managedObject()}).sorted(by: {$0.createdDate! > $1.createdDate!})
                
                self?.allRecipes = self?.filteredRecipes ?? []
                
                if let recipe = self?.filteredRecipes, recipe.isEmpty {
                    self?.presenter?.fetchDefaultRecipes()
                }
                
                switch changes {
                case .initial:
                    // Results are now populated and can be accessed without blocking the UI
                    self?.recipeListTableView.reloadData()
                case .update(_, _, _, _):
                    // Query results have changed, so apply them to the UITableView
                    self?.recipeListTableView.reloadData()
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                }
            }
        }
    }
    
    func fetchRecipeTypes() {
        presenter?.fetchRecipeTypes()
    }
    
    // MARK: - Table View delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRecipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recipeListTableView.dequeueReusableCell(withIdentifier: "RecipeListTableViewCell", for: indexPath) as! RecipeListTableViewCell
        
        let recipe = filteredRecipes[indexPath.row]
        
        cell.commonInit(recipe: recipe)

        return cell
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (_, recipeDetailViewController) = RecipeDetailViewController.fromStoryboard()
        
        let selectedRecipe = filteredRecipes[indexPath.row]
        recipeDetailViewController.id = selectedRecipe.id
        recipeDetailViewController.recipeTypes = recipeTypes
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(recipeDetailViewController, animated: true)
        }
    }
    
    // MARK: - Recipe Types Picker View Functions
    
    func setupPickerView() {
        let controlTextField = UITextField(frame: .zero)
        view.addSubview(controlTextField)
        
        pickerController.commonInit(delegate: self, numOfRowsInComponent: recipeTypes.count, rowsData: recipeTypes, controlTextField: controlTextField)
    }
    
    func updatePickerView() {
        pickerController.updateData(data: recipeTypes)
    }
    
    func showPickerView() {
        pickerController.showPickerView()
    }
    
    func filterRecipes(recipeTypeId: String) {
        if recipeTypeId == "all" {
            // Show all recipes
            filteredRecipes = allRecipes
        } else {
            filteredRecipes = allRecipes.filter({$0.typeId == recipeTypeId})
        }
       
        recipeListTableView.reloadData()
    }
}

// MARK: - Extensions

extension HomeViewController: RecipeListDelegate {
    
    func showLoading() {
        recipeListTableView.refreshControl = self.refreshControl
        recipeListTableView.refreshControl?.beginRefreshing()
    }
    
    func hideLoading() {
        recipeListTableView.refreshControl?.endRefreshing()
    }
    
    func fetchRecipeTypesSucceed(data: [RecipeType]) {
        recipeTypes = recipeTypes + data
        self.updatePickerView()
    }
    
    func fetchAllRecipesSucceed(data: [RecipeObject]) {
        DispatchQueue.main.async {
            self.allRecipes = data.sorted(by: { $0.createdDate! > $1.createdDate! })
            self.filteredRecipes = self.allRecipes
            self.recipeListTableView.reloadData()
        }
    }
    
    func fetchDataFailed(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    @objc private func refreshRecipeList(_ sender: Any) {
        presenter?.fetchRecipeTypes()
        presenter?.fetchAllRecipes()
    }
}

extension HomeViewController: PickerDelegate {
    func didSelectRow(id: String) {
        filterRecipes(recipeTypeId: id)
    }
}

