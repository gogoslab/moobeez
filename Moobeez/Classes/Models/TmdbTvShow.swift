//
//  TmdbTvShow.swift
//  Moobeez
//
//  Created by Radu Banea on 09/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension TmdbTvShow {
    
    static var links:[Int64 : URL] = [Int64 : URL]()
    
    static func create(tmdbDictionary: [String : Any], insert:Bool = true) -> TmdbTvShow {
        
        var tvShow:TmdbTvShow? = nil
        
        if let value = tmdbDictionary["id"] {
            let tmdbId = (value as! NSNumber).int64Value
            tvShow = tvShowWithId(tmdbId)
        }
        
        if tvShow == nil {
            tvShow = TmdbTvShow.init(entity: NSEntityDescription.entity(forEntityName: "TmdbTvShow", in: MoobeezManager.shared.tmdbDatabase.context)!, insertInto: insert ? MoobeezManager.shared.tmdbDatabase.context : nil)
        }
        
        tvShow!.addEntriesFrom(tmdbDictionary: tmdbDictionary)
        
        if (insert) {
            links[tvShow!.tmdbId] = tvShow?.objectID.uriRepresentation()
        }
        
        return tvShow!
    }
    
    static func tvShowWithId(_ tmdbId:Int64) -> TmdbTvShow? {
        
        guard links[tmdbId] != nil else {
            return nil
        }
        
        let tvShow = MoobeezManager.shared.tmdbDatabase.context.object(with: (MoobeezManager.shared.tmdbDatabase.context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: links[tmdbId]!))!) as! TmdbTvShow
        
        return tvShow
        
    }
    
    static func updateLinks() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TmdbTvShow")
        
        do {
            let fetchedItems:[TmdbTvShow] = try MoobeezManager.shared.tmdbDatabase.context.fetch(fetchRequest) as! [TmdbTvShow]
            
            for item in fetchedItems {
                links[item.tmdbId] = item.objectID.uriRepresentation()
            }
            
        } catch {
            fatalError("Failed to fetch tv shows: \(error)")
        }
    }
    
    static func fetchTvShowWithId(_ tmdbId:Int64) -> TmdbTvShow? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TmdbTvShow")
        fetchRequest.predicate = NSPredicate(format: "tmdbId == %ld", tmdbId)
        
        do {
            let fetchedItems:[TmdbTvShow] = try MoobeezManager.shared.tmdbDatabase.context.fetch(fetchRequest) as! [TmdbTvShow]
            
            if fetchedItems.count > 0 {
                return fetchedItems[0]
            }
            
        } catch {
            fatalError("Failed to fetch tvShows: \(error)")
        }
        
        return nil
    }
    
    func addEntriesFrom(tmdbDictionary: [String : Any]) {
        
        if let value = tmdbDictionary["id"] {
            tmdbId = (value as! NSNumber).int64Value
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
        
        if let seasonsList = tmdbDictionary["seasons"] as? Array<Dictionary<String, Any>>{
            for seasonDictionary:Dictionary<String, Any> in seasonsList {
                let season:TmdbTvSeason = TmdbTvSeason.create(tmdbDictionary: seasonDictionary)
                
                if (seasons?.contains(season))! == false {
                    addToSeasons(season)
                }
            }
        }
        
        if let value = tmdbDictionary["number_of_seasons"] {
            seasonsCount = (value as! NSNumber).int16Value
        }
    }
    
    
    
    func seasonWithNumber(number:Int16) -> TmdbTvSeason
    {
        if seasons != nil {
            for season:TmdbTvSeason in seasons?.array as! [TmdbTvSeason]
            {
                if (season.seasonNumber == number)
                {
                    return season
                }
            }
        }
        
        let season:TmdbTvSeason = NSEntityDescription.insertNewObject(forEntityName: "TmdbTvSeason", into: MoobeezManager.shared.tmdbDatabase.context) as! TmdbTvSeason
        
        season.seasonNumber = number
        season.tvShow = self

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
    
}
