//
//  TmdbService+Movies.swift
//  Moobeez
//
//  Created by Radu Banea on 11/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation

typealias ConnectionMovieHandler = (_ error: Error?, _ responseContent: TmdbMovie?) -> ()

extension TmdbService {
    
    static func startMovieConnection(tmdbId:Int64, completionHandler:ConnectionMovieHandler? = nil) {
        
        _ = TmdbConnection.startConnection(urlString: "movie/\(tmdbId)", parameters: ["append_to_response" : "casts"], contentType: ContentType.json) { (error, responseContent, code) in
            
            var movie: TmdbMovie? = nil
            
            if error == nil {
                
                let content: Dictionary<String, Any> = responseContent as! Dictionary<String, Any>
                
                movie = TmdbMovie.create(tmdbDictionary: content)
            }
            
            if completionHandler != nil {
                completionHandler!(error, movie)
            }
            
        }
        
    }
    
    static func startMovieConnection(movie:TmdbMovie, completionHandler:ConnectionMovieHandler? = nil) {
        
        _ = TmdbConnection.startConnection(urlString: "movie/\(movie.tmdbId)", parameters: ["append_to_response" : "casts"], contentType: ContentType.json) { (error, responseContent, code) in
            
            if error == nil {
                movie.addEntriesFrom(tmdbDictionary: responseContent as! [String : Any])
            }
            
            if completionHandler != nil {
                completionHandler!(error, movie)
            }
            
        }
        
    }
    
}
