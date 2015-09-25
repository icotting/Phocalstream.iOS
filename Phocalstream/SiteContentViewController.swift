//
//  SiteContentViewController.swift
//  Phocalstream
//
//  Created by Ian Cottingham on 5/21/15.
//  Copyright (c) 2015 JS Raikes School. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SiteContentViewController: UIViewController {

    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var siteNameLabel: UILabel!
    @IBOutlet weak var siteDetailsLabel: UILabel!

    var collectionID: Int64!
    var coverPhotoID: Int64!
    var siteName: String!
    var siteDetails: String!
    
    var pageIndex: Int!
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.translucent = true
        
        self.siteNameLabel.text = self.siteName
        self.siteDetailsLabel.text = self.siteDetails
        
        let request = NSMutableURLRequest(URL: NSURL(string: String(format: "http://images.plattebasintimelapse.org/api/photo/medium/%d", coverPhotoID))!)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.coverPhoto.image = UIImage(data: data!)
                self.view.setNeedsDisplay()
            })
        })
        
        task.resume()
    }    
}
