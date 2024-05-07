//
//  Tmdb.Season.swift
//  Moobeez
//
//  Created by Radu Banea on 09/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import Foundation
import CoreData

extension Tmdb {
    
    class Season: Codable {
        
        var id: String = ""
        
        var date: Date?
        
        var seasonId: Int = 0
        var seasonNumber: Int = 1
        var name: String = ""
        
        var overview: String?
        
        var posterPath: String?
        
        var tvShow: TvShow?
        
        var episodes: [Episode] = []
        
        enum CodingKeys: String, CodingKey {
            case id
            case date
            case seasonId
            case seasonNumber
            case name
            case overview
            case posterPath
            case episodes
        }
        
        init(seasonNumber: Int) {
            self.seasonNumber = seasonNumber
        }
        
        init (tmdbDictionary: [String : Any]) {
            addEntriesFrom(tmdbDictionary: tmdbDictionary)
        }
        
        func addEntriesFrom(tmdbDictionary: [String : Any]) {
            
            if let value = tmdbDictionary["id"] {
                id = (value as! NSNumber).stringValue
            }
            
            if let value = tmdbDictionary["season_number"] {
                seasonNumber = (value as! NSNumber).intValue
            }
            
            if let value = tmdbDictionary["air_date"] {
                if value is String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    date = dateFormatter.date(from: value as! String)
                }
            }
            
            if let value = tmdbDictionary["poster_path"] {
                if value is String {
                    posterPath = value as? String
                }
            }
            
            if let episodesList = tmdbDictionary["episodes"] {
                if episodesList is Array<Dictionary<String, Any>> {
                    for episodeDictionary:Dictionary<String, Any> in (episodesList as! Array) {
                        
                        if let id = (episodeDictionary["id"] as? NSNumber)?.stringValue {
                            if let episode = episodes.first(where: { episode in
                                episode.id == id
                            }) {
                                episode.addEntriesFrom(tmdbDictionary: episodeDictionary)
                                continue
                            }
                        }
                        
                        let episode = Episode(tmdbDictionary: episodeDictionary)
                        
                        addToEpisodes(episode)
                    }
                }
            }
        }
        
        func episodeWithNumber(number: Int) -> Episode
        {
            for episode in episodes
            {
                if (episode.episodeNumber == number)
                {
                    return episode
                }
            }
            
            let episode = Episode(episodeNumber: number)
            
            addToEpisodes(episode)
            
            return episode
        }
        
        func addToEpisodes(_ episode: Episode) {
            episode.season = self
            
            episodes.append(episode)
        }
        
    }
}
