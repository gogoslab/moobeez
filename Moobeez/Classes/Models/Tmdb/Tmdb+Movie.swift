//
//  Tmdb.Movie.swift
//  Moobeez
//
//  Created by Radu Banea on 11/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension Tmdb {
    enum TrailerType: Codable {
        case quicktime;
        case youtube;
    }
    
    class Movie: Item, Codable {
        
        var id: String = ""
        
        var name: String = ""
        var overview: String = ""
        
        var imdbId: String?
        
        var backdropPath: String?
        var posterPath: String?
        
        var comments: String?
        
        var popularity: Float = 0
        
        var releaseDate: Date?
        
        var trailerPath: String?
        var trailerType: TrailerType = .youtube
        
        var charactersIds: Set<String> = []
        
        var backdropImages: [Image] = []
        var posters: [Image] = []
        
        
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
            
            case trailerPath
            case trailerType
            
            case charactersIds
            
            case backdropImages
            case posters
        }
        
        init (tmdbDictionary: [String : Any]) {
            addEntriesFrom(tmdbDictionary: tmdbDictionary)
            Movies[id] = self
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
            
            if let credits = tmdbDictionary["casts"] as? Dictionary<String, Any> {
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
            
            if let images = tmdbDictionary["images"] {
                if images is Dictionary<String, Any> {
                    if let backdrops = (images as! Dictionary<String, Any>)["backdrops"] {
                        if backdrops is Array<Dictionary<String, Any>> {
                            for imageDictionary:Dictionary<String, Any> in (backdrops as! Array) {
                                
                                let image = Image(tmdbDictionary: imageDictionary)
                                
                                addToBackdropImages(image)
                            }
                        }
                    }
                    
                    if let posters = (images as! Dictionary<String, Any>)["posters"] {
                        if posters is Array<Dictionary<String, Any>> {
                            for imageDictionary:Dictionary<String, Any> in (posters as! Array) {
                                
                                let image = Image(tmdbDictionary: imageDictionary)
                                
                                addToPosters(image)
                            }
                        }
                    }
                }
            }
            
            if let value = tmdbDictionary["imdb_id"] {
                if value is String {
                    imdbId = value as? String
                }
            }
            
            if let trailers = tmdbDictionary["trailers"] {
                if trailers is Dictionary<String, Any> {
                    
                    if trailerPath == nil {
                        if let quicktime = (trailers as! Dictionary<String, Any>)["quicktime"] {
                            if quicktime is Array<Dictionary<String, Any>> {
                                
                                for trailerDictionary:Dictionary<String, Any> in (quicktime as! Array) {
                                    if let sources = trailerDictionary["sources"] {
                                        if sources is Array<Dictionary<String, Any>> {
                                            
                                            for source:Dictionary<String, Any> in (sources as! Array) {
                                                
                                                if source["size"] as! String == "720p" {
                                                    trailerPath = source["source"] as? String
                                                    trailerType = TrailerType.quicktime
                                                }
                                                
                                                if trailerPath == nil && source["size"] as! String == "480p" {
                                                    trailerPath = source["source"] as? String
                                                    trailerType = TrailerType.quicktime
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    
                    if trailerPath == nil {
                        
                        if let youtube = (trailers as! Dictionary<String, Any>)["youtube"] {
                            if youtube is Array<Dictionary<String, Any>> {
                                
                                for trailerDictionary:Dictionary<String, Any> in (youtube as! Array) {
                                    
                                    trailerPath = trailerDictionary["source"] as? String
                                    trailerType = TrailerType.youtube
                                    
                                    break
                                }
                            }
                        }
                    }
                    
                    
                }
            }
            
            if let value = tmdbDictionary["release_date"] {
                if value is String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    releaseDate = dateFormatter.date(from: value as! String)
                }
            }
            
            if let value = tmdbDictionary["popularity"] {
                if value is NSNumber {
                    popularity = ((value as? NSNumber)?.floatValue)!
                }
            }
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
        
        func addToCharacters(_ character: Character) {
            charactersIds.insert(character.id)
            character.movie = self
        }
        
        var characters: [Character] {
            get {
                charactersIds.compactMap { id in Characters[id] }
            }
        }

        func addToBackdropImages(_ image: Image) {
            backdropImages.append(image)
        }
        
        func addToPosters(_ image: Image) {
            posters.append(image)
        }
        
    }
}
