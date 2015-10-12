//
//  RequestManager.swift
//  Phocalstream.iOS
//
//  Created by Ian Cottingham on 9/27/14.
//  Copyright (c) 2014 Jeffrey S. Raikes School. All rights reserved.
//

import UIKit
import Foundation

protocol RequestManagerDelegate {
    func didFailWithResponseCode(code: Int, message: String?)
    func didSucceedWithBody(body: Array<AnyObject>?)
    func didSucceedWithObjectId(id: Int64)
}

class RequestManager: NSObject {
    
    var delegate: RequestManagerDelegate?
    
    init(delegate: RequestManagerDelegate) {
        self.delegate = delegate
    }
    
    func makeJsonCallWithEndpoint(endPoint: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: endPoint)!)
        request.HTTPMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            
            if (error == nil && statusCode >= 200 && statusCode < 300) {
                var error: NSError?
                let json:AnyObject?
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                } catch let error1 as NSError {
                    error = error1
                    json = nil
                    print("Error parsing JSON result: \(error)")
                } catch {
                    fatalError()
                }
                self.delegate?.didSucceedWithBody(json as? Array)
            } else {

                // todo: add the status code here
                self.delegate?.didFailWithResponseCode(statusCode, message: nil)
            }
        })
        
        task.resume()
    }
    
    func postWithData(endpoint: String, data: NSDictionary) {
        let request = NSMutableURLRequest(URL: NSURL(string: endpoint)!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let postData: NSData
        do {
            // use jsonData
            try postData = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.PrettyPrinted)
            request.HTTPBody = postData
        } catch let error1 as NSError{
            print("json error: \(error1.localizedDescription)")
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            
            if (error == nil && statusCode >= 200 && statusCode < 300) {
                self.delegate?.didSucceedWithBody([NSString(data: data!, encoding: NSUTF8StringEncoding)!])
            } else {
                self.delegate?.didFailWithResponseCode(statusCode, message: nil)
            }
        })
        
        task.resume()
    }
    
    func uploadPhoto(endpoint: String, image: UIImage){
        // Scale Image
        let mediumImage = image.resizedImage(CGSizeMake(image.size.width / 2, image.size.height / 2), quality: CGInterpolationQuality.Medium)
        let imageData = UIImagePNGRepresentation(mediumImage)
        
        let request = NSMutableURLRequest(URL: NSURL(string: endpoint)!)
        request.HTTPMethod = "POST"
        
        let boundary = NSString(format: "---------------------------14737809831466499882746641449")
        let contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
        request.addValue(contentType as String, forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        // Title
        body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(NSString(format:"Content-Disposition: form-data; name=\"title\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Image Upload".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        let currentDateString = NSDate().toString("yyyy-MM-dd'T'HH:mm:ss.SSS")
        
        // Image
        body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(NSString(format:"Content-Disposition: form-data; name=\"photo_upload\"; filename=\"\(currentDateString)\"\\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(imageData!)
        body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
        
        request.HTTPBody = body
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            if(error == nil && (response as! NSHTTPURLResponse).statusCode == 200) {
                var error: NSError?
                let json:AnyObject?
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                } catch let error1 as NSError {
                    error = error1
                    json = nil
                    print("Error parsing JSON result: \(error)")
                } catch {
                    fatalError()
                }
                self.delegate?.didSucceedWithObjectId((json!.valueForKey("id") as! NSNumber).longLongValue)
            } else {
                self.delegate?.didFailWithResponseCode((response as! NSHTTPURLResponse).statusCode, message: String(NSString(data: data!, encoding:NSUTF8StringEncoding)))
            }
        })
        task.resume()
    }
    
}