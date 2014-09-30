//
//  SiteListTableViewDelegate.swift
//  Phocalstream.iOS
//
//  Created by Ian Cottingham on 9/29/14.
//  Copyright (c) 2014 Jeffrey S. Raikes School. All rights reserved.
//

import UIKit

class SiteListTableViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
   
    var sites: Array<AnyObject>?
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (sites != nil) {
            return sites!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SITE", forIndexPath: indexPath) as SiteTableViewCell
        
        let details = (self.sites![indexPath.row] as NSDictionary).objectForKey("Details") as NSDictionary
        let name = details.objectForKey("SiteName") as String
        
        let coverUrl = NSURL.URLWithString(NSString(format: "http://images.plattebasintimelapse.org/api/photo/low/%lu", details.objectForKey("CoverPhotoID")! as Int))
        cell.coverImage.image = UIImage(
            data: NSData.dataWithContentsOfURL(coverUrl, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: nil)
        )
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        let dateReader = NSDateFormatter()
        dateReader.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let start = dateReader.dateFromString(details.objectForKey("First") as String)
        let end = dateReader.dateFromString(details.objectForKey("Last") as String)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        cell.siteDescription.text = NSString(format: "%d photos from %@ to %@",
            details.objectForKey("PhotoCount") as Int,
            dateFormatter.stringFromDate(start!),
            dateFormatter.stringFromDate(end!))
        cell.siteName.text = name
        return cell
    }
}
