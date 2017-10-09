//
//  TmdbService+People.swift
//  Moobeez
//
//  Created by Radu Banea on 06/10/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation

typealias ConnectionPersonHandler = (_ error: Error?, _ responseContent: TmdbPerson?) -> ()

extension TmdbService {
    
    static func startPersonConnection(personId:Int64, completionHandler:ConnectionPersonHandler? = nil) {
        
        _ = TmdbConnection.startConnection(urlString: "person/\(personId)", parameters: ["append_to_response" : "combined_credits,images"], contentType: ContentType.json) { (error, responseContent, code) in
            
            var person: TmdbPerson? = nil
            
            if error == nil {
                
                let content: Dictionary<String, Any> = responseContent as! Dictionary<String, Any>
                
                person = TmdbPerson.create(tmdbDictionary: content)
            }
            
            if completionHandler != nil {
                completionHandler!(error, person)
            }
            
        }
    }
    
    static func startPersonConnection(person:TmdbPerson, completionHandler:ConnectionPersonHandler? = nil) {
        
        _ = TmdbConnection.startConnection(urlString: "person/\(person.personId)", parameters: ["append_to_response" : "combined_credits,images"], contentType: ContentType.json) { (error, responseContent, code) in
            
            if error == nil {
                person.addEntriesFrom(tmdbDictionary: responseContent as! [String : Any])
            }
            
            if completionHandler != nil {
                completionHandler!(error, person)
            }
            
        }
        
    }
}
