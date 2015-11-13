//
//  PhocalstreamSite.swift
//  Phocalstream
//
//  Created by Zach Christensen on 11/12/15.
//  Copyright © 2015 JS Raikes School. All rights reserved.
//

import Foundation

class PhocalstreamSite {

    var details: Details
    var latitude: Double
    var longitude: Double

    init(details: Details, latitude: Double, longitude: Double) {
        self.details = details
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(json: AnyObject) {
        self.details = Details(json: json.objectForKey("Details")!)
        self.latitude = json.objectForKey("Latitude") as! Double
        self.longitude = json.objectForKey("Longitude") as! Double
    }

}

class Details {

    var siteName: String
    var first: NSDate
    var last: NSDate
    var photoCount: Int
    var siteId: Int64
    var coverPhotoId: Int64
    
    init(siteName: String, first: String, last: String, photoCount: Int, siteId: Int64, coverPhotoId: Int64) {
        self.siteName = siteName
        self.first = NSDate(dateString: first)
        self.last = NSDate(dateString: last)
        self.photoCount = photoCount
        self.siteId = siteId
        self.coverPhotoId = coverPhotoId
    }
    
    init(json: AnyObject) {
        self.siteName = json.objectForKey("SiteName") as! String
        self.first = NSDate(dateString: json.objectForKey("First") as! String)
        self.last = NSDate(dateString: json.objectForKey("Last") as! String)
        self.photoCount = json.objectForKey("PhotoCount") as! Int
        self.siteId = (json.objectForKey("SiteID") as! NSNumber).longLongValue
        self.coverPhotoId = (json.objectForKey("CoverPhotoID") as! NSNumber).longLongValue
    }
}


