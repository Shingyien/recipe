//
//  Storyboards.swift
//  Recipe
//
//  Created by Shing Yien on 28/11/2020.
//

import UIKit

protocol StoryboardType {
    static var storyboardName: String { get }
}

enum Storyboards {
    enum Main: StoryboardType {
        static let storyboardName = "Main"
        
        static let initialScene = InitialSceneType<UIKit.UITabBarController>(storyboard: Main.self)
    }
    
    enum Home: StoryboardType {
        static let storyboardName = "Home"
        
        static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Home.self)
    }
    
    enum RecipeDetail: StoryboardType {
        static let storyboardName = "RecipeDetail"
        
        static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: RecipeDetail.self)
    }
    
    enum Profile: StoryboardType {
        static let storyboardName = "Profile"
        
        static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Profile.self)
    }
    
    enum EditRecipe: StoryboardType {
        static let storyboardName = "EditRecipe"
        
        static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: EditRecipe.self)
    }
    
}

extension StoryboardType {
    static var storyboard: UIStoryboard {
        let name = self.storyboardName
        return UIStoryboard(name: name, bundle: nil)
    }
}

struct InitialSceneType<T: UIViewController> {
    internal let storyboard: StoryboardType.Type
    
    internal func instantiate() -> T {
        guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
            fatalError("ViewController is not of the expected class \(T.self).")
        }
        return controller
    }
}
