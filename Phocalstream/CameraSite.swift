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
    
    init(coverPhotoID: Int64, name: String) {
        self.coverPhotoID = coverPhotoID
        self.name = name
    }
    
    init(json: AnyObject) {
        self.coverPhotoID = (json.objectForKey("CoverPhotoID") as? NSNumber)?.longLongValue
        self.name = json.objectForKey("Name") as? String
    }
}