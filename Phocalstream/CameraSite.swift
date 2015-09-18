//
//  CameraSite.swift
//  Phocalstream
//
//  Created by Ian Cottingham on 5/21/15.
//  Copyright (c) 2015 JS Raikes School. All rights reserved.
//

import Foundation

class CameraSite {
    
    var coverPhotoID: Int64?
    var name: String?
    var photoCount: Int?
    var from: NSDate?
    var to: NSDate?
    
    init(coverPhotoID: Int64, name: String, photoCount: Int, from: NSDate, to: NSDate) {
        self.coverPhotoID = coverPhotoID
        self.name = name
        self.photoCount = photoCount
        self.from = from
        self.to = to
    }
    
    init(json: AnyObject) {
        self.coverPhotoID = (json.objectForKey("CoverPhotoID") as? NSNumber)?.longLongValue
        self.name = json.objectForKey("Name") as? String
        self.photoCount = json.objectForKey("PhotoCount") as? Int
        self.from = NSDate(dateString: (json.objectForKey("From") as? String)!)
        self.to = NSDate(dateString: (json.objectForKey("To") as? String)!)
    }
}