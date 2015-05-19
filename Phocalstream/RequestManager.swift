//
//  RequestManager.swift
//  Phocalstream.iOS
//
//  Created by Ian Cottingham on 9/27/14.
//  Copyright (c) 2014 Jeffrey S. Raikes School. All rights reserved.
//

import UIKit

protocol RequestManagerDelegate {
    func didFailWithResponseCode(code: Int)
    func didSucceedWithBody(body: Array<AnyObject>?)
}

class RequestManager: NSObject {
    
    var delegate: RequestManagerDelegate?
    
    init(delegate: RequestManagerDelegate) {
        self.delegate = delegate
    }
    
    func makeJsonCallWithEndpoint(endPoint: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: endPoint)!)
        request.HTTPMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            
            if (error == nil && statusCode >= 200 && statusCode < 300) {
                var error: NSError?
                let json:AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error)
                self.delegate?.didSucceedWithBody(json as? Array)
            } else {

                // todo: add the status code here
                self.delegate?.didFailWithResponseCode(statusCode)
            }
        })
        
        task.resume()
    }
    
}