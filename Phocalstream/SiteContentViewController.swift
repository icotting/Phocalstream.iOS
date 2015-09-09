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

    var coverPhotoID: Int64!
    var siteName: String!
    
    override func viewDidLoad() {
        self.siteNameLabel.text = self.siteName
        
        var request = NSMutableURLRequest(URL: NSURL(string: String(format: "http://images.plattebasintimelapse.org/api/photo/low/%d", coverPhotoID))!)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            self.coverPhoto.image = UIImage(data: data)
            self.view.setNeedsDisplay()
        })
        
        task.resume()
    }
}
