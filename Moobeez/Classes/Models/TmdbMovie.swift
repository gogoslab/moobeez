//
//  TmdbMovie.swift
//  Moobeez
//
//  Created by Radu Banea on 11/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum TrailerType: Int16 {
    case quicktime = 0;
    case youtube = 1;
}

extension TmdbMovie {
    
    static var links:[Int64 : URL] = [Int64 : URL]()
    
    static func create(tmdbDictionary: [String : Any], insert:Bool = true) -> TmdbMovie {
        
        var movie:TmdbMovie? = nil
        
        if let value = tmdbDictionary["id"] {
            let tmdbId = (value as! NSNumber).int64Value
            movie = movieWithId(tmdbId)
        }
        
        if movie == nil {
            movie = TmdbMovie.init(entity: NSEntityDescription.entity(forEntityName: "TmdbMovie", in: MoobeezManager.tempDataContex!)!, insertInto: insert ? MoobeezManager.tempDataContex : nil)
        }
        
        movie!.addEntriesFrom(tmdbDictionary: tmdbDictionary)

        if (insert) {
            links[movie!.tmdbId] = movie?.objectID.uriRepresentation()
        }

        return movie!
    }
    
    static func movieWithId(_ tmdbId:Int64) -> TmdbMovie? {
        
        guard links[tmdbId] != nil else {
            return nil
        }
        
        let movie = MoobeezManager.tempDataContex!.object(with: (MoobeezManager.tempDataContex!.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: links[tmdbId]!))!) as! TmdbMovie
        
        return movie
        
    }
    
    static func updateLinks() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TmdbMovie")
        
        do {
            let fetchedItems:[TmdbMovie] = try MoobeezManager.tempDataContex!.fetch(fetchRequest) as! [TmdbMovie]
            
            for item in fetchedItems {
                links[item.tmdbId] = item.objectID.uriRepresentation()
            }
            
        } catch {
            fatalError("Failed to fetch movies: \(error)")
        }
    }
    
    static func fetchMovieWithId(_ tmdbId:Int64) -> TmdbMovie? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TmdbMovie")
        fetchRequest.predicate = NSPredicate(format: "tmdbId == %ld", tmdbId)
        
        do {
            let fetchedItems:[TmdbMovie] = try MoobeezManager.tempDataContex!.fetch(fetchRequest) as! [TmdbMovie]
            
            if fetchedItems.count > 0 {
                return fetchedItems[0]
            }
            
        } catch {
            fatalError("Failed to fetch movies: \(error)")
        }
        
        return nil
    }
    
    func addEntriesFrom(tmdbDictionary: [String : Any]) {
        
        if let value = tmdbDictionary["id"] {
            tmdbId = (value as! NSNumber).int64Value
        }
        
        if let value = tmdbDictionary["title"] {
            if value is String {
                name = value as? String
            }
        }
        
        if let value = tmdbDictionary["overview"] {
            if value is String {
                overview = value as? String
            }
        }
        
        if let value = tmdbDictionary["poster_path"] {
            if value is String {
                posterPath = value as? String
            }
        }
        
        if let value = tmdbDictionary["backdrop_path"] {
            if value is String {
                backdropPath = value as? String
            }
        }
        
        if let casts = tmdbDictionary["casts"] {
            if casts is Dictionary<String, Any> {
                if let cast = (casts as! Dictionary<String, Any>)["cast"] {
                    if cast is Array<Dictionary<String, Any>> {
                        
                        for characterDictionary:Dictionary<String, Any> in (cast as! Array) {
                            
                            let character:TmdbCharacter = TmdbCharacter.create(tmdbDictionary: characterDictionary)
                            
                            if character.movie == nil {
                                character.movie = self
                                addToCharacters(character)
                            }
                            
                            if character.person == nil {
                                let person:TmdbPerson = TmdbPerson.create(tmdbDictionary: characterDictionary)
                                person.addToCharacters(character)
                                character.person = person
                            }                            
                        }
                    }
                }
            }
        }
        
        if let images = tmdbDictionary["images"] {
            if images is Dictionary<String, Any> {
                if let backdrops = (images as! Dictionary<String, Any>)["backdrops"] {
                    if backdrops is Array<Dictionary<String, Any>> {
                        for imageDictionary:Dictionary<String, Any> in (backdrops as! Array) {
                            
                            let image:TmdbImage = TmdbImage.create(tmdbDictionary: imageDictionary)
                            
                            addToBackdropImages(image)
                        }
                    }
                }
                
                if let posters = (images as! Dictionary<String, Any>)["posters"] {
                    if posters is Array<Dictionary<String, Any>> {
                        for imageDictionary:Dictionary<String, Any> in (posters as! Array) {
                            
                            let image:TmdbImage = TmdbImage.create(tmdbDictionary: imageDictionary)
                            
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
                    
                    if let youtube = (trailers as! Dictionary<String, Any>)["youtube"] {
                        if youtube is Array<Dictionary<String, Any>> {
                            
                            for trailerDictionary:Dictionary<String, Any> in (youtube as! Array) {
                                
                                trailerPath = trailerDictionary["source"] as? String
                                trailerType = TrailerType.youtube.rawValue
                                
                                break
                            }
                        }
                    }
                }
                
                if trailerPath == nil {
                    if let quicktime = (trailers as! Dictionary<String, Any>)["quicktime"] {
                        if quicktime is Array<Dictionary<String, Any>> {
                            
                            for trailerDictionary:Dictionary<String, Any> in (quicktime as! Array) {
                                if let sources = trailerDictionary["sources"] {
                                    if sources is Array<Dictionary<String, Any>> {
                                        
                                        for source:Dictionary<String, Any> in (sources as! Array) {
                                            
                                            if source["size"] as! String == "720p" {
                                                trailerPath = source["source"] as? String
                                                trailerType = TrailerType.quicktime.rawValue
                                            }
                                            
                                            if trailerPath == nil && source["size"] as! String == "480p" {
                                                trailerPath = source["source"] as? String
                                                trailerType = TrailerType.quicktime.rawValue
                                            }
                                        }
                                    }
                                }
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
            
            if UIApplication.shared.canOpenURL(url) == false {
                url = URL(string: "http://m.imdb.com/title/\((imdbId)!)/")!
            }
            
            return url
        }
    }
    
}
