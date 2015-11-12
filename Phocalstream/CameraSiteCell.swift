//
//  CameraSiteCell.swift
//  Phocalstream
//
//  Created by Zach Christensen on 11/11/15.
//  Copyright © 2015 JS Raikes School. All rights reserved.
//

import Foundation
import UIKit

class CameraSiteCell : UITableViewCell {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var siteNameLabel: UILabel!
    @IBOutlet weak var photoCountBackground: UIView!
    @IBOutlet weak var photoCountLabel: UILabel!
    @IBOutlet weak var siteDetailsLabel: UILabel!

    func loadItem(site: PhocalstreamSite) {
        // name
        siteNameLabel.text = site.details.siteName
        
        // photos
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale.currentLocale()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle;
        numberFormatter.usesGroupingSeparator = true;
        
        if site.details.photoCount == 1 {
            photoCountLabel.text = "\(site.details.photoCount) photo"
        }
        else {
            photoCountLabel.text = String(format: "%@ photos", numberFormatter.stringFromNumber(site.details.photoCount)!)
        }
        self.photoCountBackground.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.5)
//        self.photoCountLabel.draw

        // details
        siteDetailsLabel.text = String(format: "From %@ to %@", (site.details.first.toString("MM/dd/YYYY")!), (site.details.last.toString("MM/dd/YYYY"))!)

        // Load Background Image
        let request = NSMutableURLRequest(URL: NSURL(string: String(format: "http://images.plattebasintimelapse.org/api/photo/medium/%d", site.details.coverPhotoId))!)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.backgroundImage.image = UIImage(data: data!)
                self.backgroundImage.setNeedsDisplay()
            })
        })
        
        task.resume()
    }

}