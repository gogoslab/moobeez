//
//  TmdbTvShow.swift
//  Moobeez
//
//  Created by Radu Banea on 09/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import CoreData

extension TmdbTvShow {
    
    static var links:[Int64 : URL] = [Int64 : URL]()
    
    static func create(tmdbDictionary: [String : Any], insert:Bool = true) -> TmdbTvShow {
        
        var tvShow:TmdbTvShow? = nil
        
        if let value = tmdbDictionary["id"] {
            let tmdbId = (value as! NSNumber).int64Value
            tvShow = tvShowWithId(tmdbId)
        }
        
        if tvShow == nil {
            tvShow = TmdbTvShow.init(entity: NSEntityDescription.entity(forEntityName: "TmdbTvShow", in: MoobeezManager.tempDataContex!)!, insertInto: insert ? MoobeezManager.tempDataContex : nil)
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
        
        let tvShow = MoobeezManager.tempDataContex!.object(with: (MoobeezManager.tempDataContex!.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: links[tmdbId]!))!) as! TmdbTvShow
        
        return tvShow
        
    }
    
    static func updateLinks() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TmdbTvShow")
        
        do {
            let fetchedItems:[TmdbTvShow] = try MoobeezManager.tempDataContex!.fetch(fetchRequest) as! [TmdbTvShow]
            
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
            let fetchedItems:[TmdbTvShow] = try MoobeezManager.tempDataContex!.fetch(fetchRequest) as! [TmdbTvShow]
            
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
        
        let season:TmdbTvSeason = NSEntityDescription.insertNewObject(forEntityName: "TmdbTvSeason", into: MoobeezManager.shared.tempContainer.viewContext) as! TmdbTvSeason
        
        season.seasonNumber = number
        season.tvShow = self

        addToSeasons(season)
        
        return season
    }
    
}
