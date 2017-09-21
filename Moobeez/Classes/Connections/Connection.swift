//
//  Connection.swift
//  Moobeez
//
//  Created by Radu Banea on 11/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit
//import SwiftyBeaver

enum ContentType {
    case json
    case encoded
    case url
}

enum HttpMethod: String {
    case GET = "GET"
    case POST = "POST"
}

typealias ConnectionHandler = (_ error: Error?, _ responseContent: Any?, _ responseCode: Int) -> ()
typealias ConnectionErrorHandler = (_ error: Error?) -> ()


class Connection: NSObject {
    
    class func startConnection (urlString: String,
                                method: HttpMethod,
                                headers: Dictionary<String, Any>?,
                                parameters: Dictionary<String, Any>?,
                                contentType: ContentType,
                                completionHandler: ConnectionHandler? = nil) -> Connection {
        
        let connection: Connection = Connection()
        
        connection.startConnection(urlString: urlString, method: method, headers: headers, parameters: parameters, contentType: contentType, completionHandler: completionHandler);
        
        return connection
        
    }
    
    public func startConnection (urlString: String,
                                 method: HttpMethod,
                                 headers: Dictionary<String, Any>?,
                                 parameters: Dictionary<String, Any>?,
                                 contentType: ContentType,
                                 completionHandler: ConnectionHandler? = nil) {
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        
        if (contentType == ContentType.encoded)
        {
            configuration.httpAdditionalHeaders = ["Accept" : "application/json", "Content-Type" : "application/x-www-form-urlencoded"]
        }
        else
        {
            configuration.httpAdditionalHeaders = ["Accept" : "application/json", "Content-Type" : "application/json"]
        }
        
        if headers != nil {
            headers?.forEach { configuration.httpAdditionalHeaders![$0] = $1 }
        }
        
        let session: URLSession = URLSession(configuration: configuration)
        
        var request: URLRequest = URLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = method.rawValue
        
        if parameters != nil {
            if (contentType == .url || method == .GET)
            {
                var parametersString: String = ""
                
                for (key, value) in parameters! {
                    
                    if parametersString.characters.count == 0 {
                        parametersString += "?"
                    } else {
                        parametersString += "&"
                    }
                    
                    parametersString += key + "=" + (value as! String)
                }
                
                request.url = URL(string:urlString + parametersString)
            }
            else
            {
                if contentType != .url
                {
                    
                }
            }
        }
        
        let task = session.dataTask(with: request) { (data: Data?, response:URLResponse?, error:Error?) in
            
            guard completionHandler != nil else {
                return
            }
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            if error == nil {
                
                do
                {
                    let responseContent = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    
//                    SwiftyBeaver.info("response to \(String(describing: request.url?.absoluteString)):\n\(responseContent)")
                    
                    completionHandler!(nil, responseContent, statusCode)
                }
                catch let jsonError
                {
//                    SwiftyBeaver.error("response to \(String(describing: request.url?.absoluteString)):\n\(jsonError.localizedDescription)")

                    completionHandler!(jsonError, nil, statusCode)
                }
            }
            else
            {
//                SwiftyBeaver.error("response to \(String(describing: request.url?.absoluteString)):\n\(String(describing: error?.localizedDescription))")

                completionHandler!(error, nil, statusCode)
            }
            
        }
        
        task.resume()
    }

}
