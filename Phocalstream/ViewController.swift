//
//  ViewController.swift
//  Phocalstream
//
//  Created by Ian Cottingham on 5/18/15.
//  Copyright (c) 2015 JS Raikes School. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate, AuthenticationDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ( FBSDKAccessToken.currentAccessToken() == nil ) {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
        else {
            let auth = AuthenticationManager(delegate: self)
            auth.login(FBSDKAccessToken.currentAccessToken().tokenString)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Fb Delegate Methods
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil)
        {
            println("error")
        }
        else if result.isCancelled {
            println("cancelled")
        }
        else {
            let auth = AuthenticationManager(delegate: self)
            auth.login(result.token.tokenString)
        }
        
    }
        
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) { }
    

    // MARK: Authentication Delegate Methods
    func didAuthenticate()
    {
        println("Logged in!")
    }
    
    func didFailAuthentication(type: FailureType, message: String)
    {
        var view: UIAlertView? = nil
        switch type {
        case .FORBIDDEN:
            view = UIAlertView(title:"No Account", message:"You do not have a Phocalstream account. Visit the Phocalstream site to create one.", delegate:self, cancelButtonTitle:"OK")
            view!.addButtonWithTitle("Visit Site")
        case .UNAUTHORIZED:
            view = UIAlertView(title:"Authentication Failed", message:"Facebook failed to validate your login. Please try again.", delegate:self, cancelButtonTitle:"OK")
        default:
            view = UIAlertView(title:"Error", message:"An error occurred verifying your account with Phocalstream.", delegate:self, cancelButtonTitle:"OK")
        }
        view!.show()
    }
}

