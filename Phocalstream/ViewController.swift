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
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var browseSitesButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.gradientView.bounds
        let clearColor = UIColor.clearColor().CGColor as CGColorRef
        let darkColor = UIColor.blackColor().CGColor as CGColorRef
        gradientLayer.colors = [clearColor, darkColor]
        gradientLayer.locations = [0.0, 0.70]
        self.gradientView.layer.addSublayer(gradientLayer)
        
        // color button - #009688
        browseSitesButton.backgroundColor = UIColor(red: 106.0/255.0, green: 170.0/255.0, blue: 195.0/255.0, alpha: 1.0)
        browseSitesButton.layer.cornerRadius = 4
        browseSitesButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
        
        // Load Background Image
        let request = NSMutableURLRequest(URL: NSURL(string: String(format: "http://images.plattebasintimelapse.org/api/photo/medium/%d", 235364))!)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.backgroundImage.image = UIImage(data: data!)
                self.view.setNeedsDisplay()
            })
        })
        
        task.resume()
        
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
        print("Logged in!")
        self.performSegueWithIdentifier("LOADSITES", sender: self)
    }
    
    func didFailAuthentication(type: FailureType, message: String)
    {
        var alertView: UIAlertController? = nil
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { action -> Void in
            // simply cancel the alert
        })
        
        switch type {
        case .FORBIDDEN:
            alertView = UIAlertController(title: "No Account", message: "You do not have a Phocalstream account. Visit the Phocalstream site to create one.", preferredStyle: UIAlertControllerStyle.Alert)
            alertView?.addAction(cancelAction)
            alertView?.addAction(UIAlertAction(title: "Visit Site", style: UIAlertActionStyle.Default, handler: { action -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: "http://images.plattebasintimelapse.com/account/login")!)
            }))
            break
        case .UNAUTHORIZED:
            alertView = UIAlertController(title: "Authentication Failed", message: "Facebook failed to validate your login. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alertView?.addAction(cancelAction)
            break
        case .PASSTHROUGH:
            alertView = UIAlertController(title: "Authentication Failed", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alertView?.addAction(cancelAction)
            break
        default:
            alertView = UIAlertController(title: "Error", message: "An error occurred verifying your account with Phocalstream.", preferredStyle: UIAlertControllerStyle.Alert)
            alertView?.addAction(cancelAction)
        }
        self.presentViewController(alertView!, animated: true, completion: nil)
    }
    
    // MARK: AlertView Delegate Methods
    
    
}

