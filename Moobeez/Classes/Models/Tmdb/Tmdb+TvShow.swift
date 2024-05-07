//
//  Tmdb.TvShow.swift
//  Moobeez
//
//  Created by Radu Banea on 09/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension Tmdb {
    
    class TvShow: Item, Codable {
        
        var id: String = ""
        
        var name: String = ""
        var overview: String = ""
        
        var imdbId: String?
        
        var backdropPath: String?
        var posterPath: String?
        
        var comments: String?
        
        var popularity: Float = 0
        
        var releaseDate: Date?
        
        var inProduction: Bool = false
        var ended: Bool = false
        var seasonsCount: Int = 0
        var episodesCount: Int = 0
        var status: String = ""
        var voteAverage: Float = 0
        
        var seasons: [Season] = []
        var charactersIds: Set<String> = []
        
        enum CodingKeys: String, CodingKey {
            case id
            
            case name
            case overview
            
            case imdbId
            
            case backdropPath
            case posterPath
            
            case comments
            
            case popularity
            
            case releaseDate
            
            case inProduction
            case ended
            case seasonsCount
            case episodesCount
            case status
            case voteAverage
            
            case seasons
            case charactersIds
        }
        
        init (tmdbDictionary: [String : Any]) {
            addEntriesFrom(tmdbDictionary: tmdbDictionary)
            TvShows[id] = self
        }
            
        func addEntriesFrom(tmdbDictionary: [String : Any]) {
            
            if let value = tmdbDictionary["id"] {
                id = (value as! NSNumber).stringValue
            }
            
            if let value = tmdbDictionary["title"] as? String {
                name = value
            }
            
            if let value = tmdbDictionary["name"] as? String {
                name = value
            }
            
            if let value = tmdbDictionary["overview"] as? String {
                overview = value
            }
            
            if let value = tmdbDictionary["poster_path"] as? String {
                posterPath = value
            }
            
            if let value = tmdbDictionary["backdrop_path"] as? String {
                backdropPath = value
            }
            
            if let credits = tmdbDictionary["credits"] as? Dictionary<String, Any> {
                if let cast = credits["cast"] as? Array<Dictionary<String, Any>> {
                    for characterDictionary:Dictionary<String, Any> in cast {
                        
                        let character = character(characterDictionary)
                        
                        if character.movie == nil {
                            addToCharacters(character)
                        }
                        
                        if character.person == nil {
                            let person = person(characterDictionary)
                            person.addToCharacters(character)
                        }
                    }
                }
            }
            
            if let seasonsList = tmdbDictionary["seasons"] as? Array<Dictionary<String, Any>>{
                for seasonDictionary:Dictionary<String, Any> in seasonsList {
                    
                    if let id = (seasonDictionary["id"] as? NSNumber)?.stringValue {
                        if let season = seasons.first(where: { season in
                            season.id == id
                        }) {
                            season.addEntriesFrom(tmdbDictionary: seasonDictionary)
                            continue
                        }
                    }
                    
                    let season = Season(tmdbDictionary: seasonDictionary)
                    
                    addToSeasons(season)
                }
            }
            
            if let value = tmdbDictionary["number_of_seasons"] {
                seasonsCount = (value as! NSNumber).intValue
            }
        }
        
        
        
        func seasonWithNumber(number:Int) -> Season
        {
            if let season = seasons.first(where: { season in
                season.seasonNumber == number
            }) {
                return season
            }
            
            let season = Season(seasonNumber: number)
            
            addToSeasons(season)
            
            return season
        }
        
        var imdbUrl:URL? {
            get {
                guard imdbId != nil else {
                    return nil
                }
                
                var url:URL = URL(string: "imdb:///title/\((imdbId)!)/")!
                
#if MAIN
                if UIApplication.shared.canOpenURL(url) == false {
                    url = URL(string: "http://m.imdb.com/title/\((imdbId)!)/")!
                }
#endif
                
                return url
            }
        }
        
        func addToSeasons(_ season: Season) {
            seasons.append(season)
            season.tvShow = self
        }
        
        func addToCharacters(_ character: Character) {
            charactersIds.insert(character.id)
            character.movie = self
        }
        
        var characters: [Character] {
            get {
                charactersIds.compactMap { id in Characters[id] }
            }
        }
        
    }
    
}
