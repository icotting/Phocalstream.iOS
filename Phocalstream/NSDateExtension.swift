//
//  NSDateExtension.swift
//  Phocalstream
//
//  Created by Zach Christensen on 9/18/15.
//  Copyright © 2015 JS Raikes School. All rights reserved.
//

import Foundation

extension NSDate {
    
    convenience init(dateString: String) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = formatter.dateFromString(dateString)
        
        self.init(timeInterval: 0, sinceDate: date!)
    }
    
    func toString(let format: String) -> String? {
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
}