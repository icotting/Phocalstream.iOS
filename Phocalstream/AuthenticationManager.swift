//
//  AuthenticationManager.swift
//  Phocalstream
//
//  Created by Ian Cottingham on 5/19/15.
//  Copyright (c) 2015 JS Raikes School. All rights reserved.
//

import Foundation

protocol AuthenticationDelegate {
    func didAuthenticate()
    func didFailAuthentication(type: FailureType, message: String)
}

enum FailureType {
    case UNAUTHORIZED
    case FORBIDDEN
    case ERROR
    case PASSTHROUGH
}

class AuthenticationManager : RequestManagerDelegate {
    
    var delegate: AuthenticationDelegate?
    
    init(delegate: AuthenticationDelegate) {
        self.delegate = delegate;
    }
    
    func login(fbToken: String) {
        let req = RequestManager(delegate: self)
        let url = String(format: "http://images.plattebasintimelapse.org/api/mobileclient/authenticate?fbToken=%@", fbToken)
        req.makeJsonCallWithEndpoint(url)
    }
    
    // MARK: RequestManager Delegate Methods
    
    func didFailWithResponseCode(code: Int) {
        switch code {
        case 403:
            self.delegate?.didFailAuthentication(FailureType.UNAUTHORIZED, message:"Invalid Facebook access token")
            break
        case 401:
            self.delegate?.didFailAuthentication(FailureType.FORBIDDEN, message:"No Phocalstream user account")
            break
        default:
            self.delegate?.didFailAuthentication(FailureType.ERROR, message:"Authentication error")
            break
        }
    }
    
    func didSucceedWithBody(body: Array<AnyObject>?) {
        self.delegate?.didAuthenticate()
    }
    
}