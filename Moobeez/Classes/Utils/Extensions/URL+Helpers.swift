//
//  URL+Helpers.swift
//  Moobeez
//
//  Created by Radu Banea on 23/11/2018.
//  Copyright © 2018 Gogo's Lab. All rights reserved.
//

import Foundation

public extension URL {
    public var parameters:[String : Any] {
        get {
            let components = NSURLComponents(url: self, resolvingAgainstBaseURL: false)
            
            guard components != nil else {
                return [:]
            }
            
            var parameters = [String : Any]()
            
            if let queryItems = components!.queryItems {
                for item in queryItems {
                    parameters[item.name] = item.value
                }
            }
            
            return parameters
        }
    }
}
