//
//  TmdbConnection.swift
//  Moobeez
//
//  Created by Radu Banea on 11/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import UIKit

enum TmdbServerConfiguration: String {
    
    case Url = "http://api.themoviedb.org/"
    case Version = "3"
    case ApiKey = "58941f25d1c85eb024206cbf1a9a89b0"
}

class TmdbConnection: Connection {

    class func startConnection (urlString: String,
                                parameters: Dictionary<String, Any>?,
                                contentType: ContentType,
                                completionHandler: ConnectionHandler? = nil) -> TmdbConnection {
        
        let connection: TmdbConnection = TmdbConnection()
        
        connection.startConnection(urlString: urlString,
                               parameters: parameters,
                               contentType: contentType,
                               completionHandler: completionHandler)
        
        return connection
        
    }
    
    public func startConnection (urlString: String,
                                 parameters: Dictionary<String, Any>?,
                                 contentType: ContentType,
                                 completionHandler: ConnectionHandler? = nil)
    {
        
        let serverUrlString = TmdbServerConfiguration.Url.rawValue + TmdbServerConfiguration.Version.rawValue + "/"
        
        var allParameters:Dictionary = parameters ?? Dictionary()
        
        allParameters["api_key"] = TmdbServerConfiguration.ApiKey.rawValue
        
        super.startConnection(urlString: serverUrlString + urlString,
                              method: HttpMethod.GET,
                              headers: nil,
                              parameters: allParameters,
                              contentType: contentType,
                              completionHandler: completionHandler)
                                
    }
}
