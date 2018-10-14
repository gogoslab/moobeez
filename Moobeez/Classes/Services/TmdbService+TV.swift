//
//  TmdbService+TV.swift
//  Moobeez
//
//  Created by Radu Banea on 11/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation

typealias ConnectionTvShowHandler = (_ error: Error?, _ responseContent: TmdbTvShow?) -> ()
typealias ConnectionSearchTvShowsHandler = (_ error: Error?, _ responseContent: [TmdbTvShow]) -> ()

extension TmdbService {
    
    static func startTvShowConnection(tmdbId:Int64, completionHandler:ConnectionTvShowHandler? = nil) {
        
        _ = TmdbConnection.startConnection(urlString: "tv/\(tmdbId)", parameters: ["append_to_response" : "credits,images,external_ids"], contentType: ContentType.json) { (error, responseContent, code) in
            
            var tvShow: TmdbTvShow? = nil
            
            if error == nil {
                
                let content: Dictionary<String, Any> = responseContent as! Dictionary<String, Any>
                
                tvShow = TmdbTvShow.create(tmdbDictionary: content)
            }
            
            if tvShow != nil && tvShow!.seasonsCount > 0 {
                startTvShowSeasonConnection(tvShow: tvShow!, seasonNumber: 1, completionHandler: completionHandler)
            }
            else if completionHandler != nil {
                completionHandler!(error, tvShow)
            }
        }
        
    }
    
    static func startTvShowConnection(tvShow:TmdbTvShow, completionHandler:ConnectionTvShowHandler? = nil) {
        
        _ = TmdbConnection.startConnection(urlString: "tv/\(tvShow.tmdbId)", parameters: ["append_to_response" : "credits,images,external_ids"], contentType: ContentType.json) { (error, responseContent, code) in
            
            if error == nil {
                tvShow.addEntriesFrom(tmdbDictionary: responseContent as! [String : Any])
            }
            
            if tvShow.seasonsCount > 0 {
                startTvShowSeasonConnection(tvShow: tvShow, seasonNumber: 1, completionHandler: completionHandler)
            }
            else if completionHandler != nil {
                completionHandler!(error, tvShow)
            }
        }
        
    }
    
    static func startSearchTvShowsConnection(query:String, completionHandler:ConnectionSearchTvShowsHandler? = nil) {
        
        _ = TmdbConnection.startConnection(urlString: "search/tv", parameters: ["query" : query], contentType: ContentType.json) { (error, responseContent, code) in
            
            var tvShows:[TmdbTvShow] = [TmdbTvShow]()
            
            if error == nil {
                
                if responseContent is Dictionary<String, Any> {
                    
                    let response = responseContent as! Dictionary<String, Any>
                    
                    let results = response["results"] as! Array<Dictionary<String, Any>>
                    
                    for tvShowDictionary in results {
                        
                        if let title:String = tvShowDictionary["name"] as? String {
                            
                            if title.lowercased().range(of: query.lowercased()) != nil {
                                
                                let tvShow:TmdbTvShow = TmdbTvShow.create(tmdbDictionary: tvShowDictionary)
                                tvShows.append(tvShow)
                                
                            }
                        }
                    }
                    
                }
            }
            
            completionHandler?(error, tvShows)
        }
    }
    
    static func startTvShowSeasonConnection(tvShow:TmdbTvShow, seasonNumber:Int16, completionHandler:ConnectionTvShowHandler? = nil) {
        
        _ = TmdbConnection.startConnection(urlString: "tv/\(tvShow.tmdbId)/season/\(seasonNumber)", parameters: nil, contentType: ContentType.json) { (error, responseContent, code) in
            
            if error == nil {
                let season:TmdbTvSeason = tvShow.seasonWithNumber(number: seasonNumber)
                season.addEntriesFrom(tmdbDictionary: responseContent as! [String : Any])
            }
            
            if seasonNumber <= tvShow.seasonsCount {
                startTvShowSeasonConnection(tvShow: tvShow, seasonNumber: seasonNumber + 1, completionHandler: completionHandler)
            }
            else {
                if completionHandler != nil {
                    completionHandler!(error, tvShow)
                }
            }
            
        }
        
    }
}
