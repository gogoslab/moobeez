//
//  TmdbService+Movies.swift
//  Moobeez
//
//  Created by Radu Banea on 11/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import Foundation

typealias ConnectionMovieHandler = (_ error: Error?, _ responseContent: Tmdb.Movie?) -> ()
typealias ConnectionSearchMoviesHandler = (_ error: Error?, _ responseContent: [Tmdb.Movie]) -> ()

extension TmdbService {
    
    static func startMovieConnection(tmdbId: String, completionHandler:ConnectionMovieHandler? = nil) {
        
        _ = TmdbConnection.startConnection(urlString: "movie/\(tmdbId)", parameters: ["append_to_response" : "casts,images,trailers"], contentType: ContentType.json) { (error, responseContent, code) in
            
            var movie: Tmdb.Movie? = nil
            
            if error == nil {
                
                let content: Dictionary<String, Any> = responseContent as! Dictionary<String, Any>
                
                movie = Tmdb.movie(content)
            }
            
            if completionHandler != nil {
                completionHandler!(error, movie)
            }
            
        }
        
    }
    
    static func startMovieConnection(movie:Tmdb.Movie, completionHandler:ConnectionMovieHandler? = nil) {
        
        _ = TmdbConnection.startConnection(urlString: "movie/\(movie.id)", parameters: ["append_to_response" : "casts,images,trailers"], contentType: ContentType.json) { (error, responseContent, code) in
            
            if error == nil {
                movie.addEntriesFrom(tmdbDictionary: responseContent as! [String : Any])
            }
            
            if completionHandler != nil {
                completionHandler!(error, movie)
            }
            
        }
        
    }
    
    static func startSearchMoviesConnection(query:String, completionHandler:ConnectionSearchMoviesHandler? = nil) {
        
        _ = TmdbConnection.startConnection(urlString: "search/movie", parameters: ["query" : query], contentType: ContentType.json) { (error, responseContent, code) in
            
            var movies:[Tmdb.Movie] = [Tmdb.Movie]()
            
            if error == nil {
                
                if responseContent is Dictionary<String, Any> {
                    
                    let response = responseContent as! Dictionary<String, Any>
                    
                    let results = response["results"] as! Array<Dictionary<String, Any>>
                    
                    for movieDictionary in results {
                        
                        if let title:String = movieDictionary["title"] as? String {
                        
                            if title.lowercased().range(of: query.lowercased()) != nil {
                                
                                let movie = Tmdb.movie(movieDictionary)
                                movies.append(movie)
                                
                            }
                        }
                    }
                    
                }
            }
            
            if completionHandler != nil {
                completionHandler!(error, movies)
            }
            
        }
        
    }
}
