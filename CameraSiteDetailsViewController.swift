//
//  CameraSiteDetailsViewController.swift
//  Phocalstream
//
//  Created by Zach Christensen on 11/12/15.
//  Copyright © 2015 JS Raikes School. All rights reserved.
//

import Foundation
import UIKit

class CameraSiteDetailsViewController : UIViewController {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    
    @IBOutlet weak var photoCountLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    @IBOutlet weak var browseOnlineButton: UIButton!
    var site: PhocalstreamSite?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.gradientView.bounds
        let clearColor = UIColor.clearColor().CGColor as CGColorRef
        let darkColor = UIColor.blackColor().CGColor as CGColorRef
        gradientLayer.colors = [clearColor, darkColor]
        gradientLayer.locations = [0.0, 0.70]
        self.gradientView.layer.addSublayer(gradientLayer)
        
        self.navigationItem.title = String(format: "%@ Details", (self.site?.details.siteName)!)
        
        // photos
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale.currentLocale()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle;
        numberFormatter.usesGroupingSeparator = true;
        
        if let photoCount = self.site?.details.photoCount {
            if photoCount == 1 {
                self.photoCountLabel.text = "\(photoCount) photo"
                
            }
            else {
                self.photoCountLabel.text = String(format: "%@ photos", numberFormatter.stringFromNumber(photoCount)!)
            }
        }
        
        // details
        self.detailsLabel.text = String(format: "From %@ to %@",
            (self.site?.details.first.toString("MM/dd/YYYY")!)!, (self.site?.details.last.toString("MM/dd/YYYY"))!)
        
        // Load Background Image
        let request = NSMutableURLRequest(URL: NSURL(string: String(format: "http://images.plattebasintimelapse.org/api/photo/medium/%d", (site?.details.coverPhotoId)!))!)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.backgroundImage.image = UIImage(data: data!)
                self.view.setNeedsDisplay()
            })
        })
        task.resume()
        
        // color button - #009688
        browseOnlineButton.backgroundColor = UIColor(red: 106.0/255.0, green: 170.0/255.0, blue: 195.0/255.0, alpha: 1.0)
        browseOnlineButton.layer.cornerRadius = 4
        browseOnlineButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
        browseOnlineButton.setTitle(String(format: "Browse %@ Online", (self.site?.details.siteName)!), forState: UIControlState.Normal)
    }
    
    @IBAction func browseOnline(sender: AnyObject) {
        let url = String(format: "http://images.plattebasintimelapse.com/photo/sitedashboard?siteId=%d", (self.site?.details.siteId)!)
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    func setSite(site: PhocalstreamSite) {
        self.site = site
    }
}