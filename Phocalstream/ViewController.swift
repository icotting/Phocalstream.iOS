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
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
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
            self.didFailAuthentication(FailureType.PASSTHROUGH, message: "Error logging in with Facebook. Please try again.")
        }
        else if result.isCancelled {
            self.didFailAuthentication(FailureType.PASSTHROUGH, message: "Logging in with Facebook was cancelled. Please try again.")
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
        self.performSegueWithIdentifier("LOADSITES", sender: self)
    }
    
    func didFailAuthentication(type: FailureType, message: String)
    {
        var view: UIAlertView? = nil
        switch type {
        case .FORBIDDEN:
            view = UIAlertView(title:"No Account", message:"You do not have a Phocalstream account. Visit the Phocalstream site to create one.", delegate:self, cancelButtonTitle:"OK")
            view!.addButtonWithTitle("Visit Site")
            break
        case .UNAUTHORIZED:
            view = UIAlertView(title:"Authentication Failed", message:"Facebook failed to validate your login. Please try again.", delegate:self, cancelButtonTitle:"OK")
            break
        case .PASSTHROUGH:
            view = UIAlertView(title:"Authentication Failed", message:message, delegate:self, cancelButtonTitle:"OK")
            break
        default:
            view = UIAlertView(title:"Error", message:"An error occurred verifying your account with Phocalstream.", delegate:self, cancelButtonTitle:"OK")
        }
        view!.show()
    }
}

