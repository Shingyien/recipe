//
//  ProfileViewController.swift
//  Recipe
//
//  Created by Shing Yien on 28/11/2020.
//

import UIKit
import FirebaseUI

class ProfileViewController: UIViewController, FUIAuthDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnSignOut: UIButton!
    
    // MARK: - Properties
    
    var authUI : FUIAuth?
    
    // MARK: - IB Actions
    
    @IBAction func onSignInButtonTouched(_ sender: Any) {
        let authViewController = (authUI?.authViewController())!
        self.present(authViewController, animated: true, completion: nil)
    }
    
    @IBAction func onSignOutButtonTouched(_ sender: Any) {
        do {
            try authUI?.signOut()
        } catch {
            print("Error signing out user.")
        }
        
        lblUsername.isHidden = true
        btnSignIn.isHidden = false
        btnSignOut.isHidden = true
    }
    
    // MARK: - View Controller Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        
        let providers: [FUIAuthProvider] = [
            FUIEmailAuth(),
            FUIAnonymousAuth()
        ]
        authUI?.providers = providers
        
        if Auth.auth().currentUser != nil {
            signInWithUser(user: Auth.auth().currentUser!)
        } else {
            lblUsername.isHidden = true
            btnSignOut.isHidden = true
        }
    }
    
    // MARK: - Firebase Auth UI Implementations
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        // handle after sign in
        guard let user = authDataResult?.user else { return }
        signInWithUser(user: user)
    }
    
    // MARK: - Internal functions
    
    private func signInWithUser(user: User) {
        if (user.isAnonymous) {
            lblUsername.text = "Welcome annonymous user \n\(user.uid)"
            btnSignOut.isHidden = false
        } else {
            lblUsername.text = "Welcome \n\(String(describing: user.displayName))"
            btnSignOut.isHidden = false
        }
        lblUsername.isHidden = false
        btnSignIn.isHidden = true
    }
}
