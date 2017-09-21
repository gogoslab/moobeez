//
//  TmdbService.swift
//  Moobeez
//
//  Created by Radu Banea on 11/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class TmdbService: NSObject {

    static func startConfigurationConnection(completionHandler:ConnectionErrorHandler? = nil) {
        
        _ = TmdbConnection.startConnection(urlString: "configuration", parameters: nil, contentType: ContentType.json) { (error, responseContent, code) in
            
            if error == nil {
                
                let content: Dictionary<String, Any> = responseContent as! Dictionary<String, Any>
                
                let imageSettings:NSDictionary = NSDictionary(dictionary: content["images"] as! Dictionary)
                
                UIImageView.tmdbRootPath = imageSettings.object(forKey: "secure_base_url") as! String

                if let path = AppDelegate.GroupPath?.appendingPathComponent("ImagesSettings.plist") {
                    do {
                        try imageSettings.write(to: path)
                    }
                    catch (_) {
                        
                    }
                }
            }
            
            if completionHandler != nil {
                completionHandler!(error)
            }
            
        }
        
    }
    
}
