//
//  TmdbTvSeason.swift
//  Moobeez
//
//  Created by Radu Banea on 09/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import CoreData

extension TmdbTvEpisode {
    
    static var links:[Int64 : URL] = [Int64 : URL]()
    
    static func create(tmdbDictionary: [String : Any], insert:Bool = true) -> TmdbTvEpisode {
        
        var episode:TmdbTvEpisode? = nil
        
        if let value = tmdbDictionary["id"] {
            let tmdbId = (value as! NSNumber).int64Value
            episode = episodeWithId(tmdbId)
        }
        
        if episode == nil {
            episode = TmdbTvEpisode.init(entity: NSEntityDescription.entity(forEntityName: "TmdbTvEpisode", in: MoobeezManager.tempDataContex!)!, insertInto: insert ? MoobeezManager.tempDataContex : nil)
        }
        
        episode!.addEntriesFrom(tmdbDictionary: tmdbDictionary)
        
        if (insert) {
            links[episode!.tmdbId] = episode?.objectID.uriRepresentation()
        }
        
        return episode!
    }
    
    static func episodeWithId(_ tmdbId:Int64) -> TmdbTvEpisode? {
        
        guard links[tmdbId] != nil else {
            return nil
        }
        
        let episode = MoobeezManager.tempDataContex!.object(with: (MoobeezManager.tempDataContex!.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: links[tmdbId]!))!) as! TmdbTvEpisode
        
        return episode
        
    }
    
    static func updateLinks() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TmdbTvSeason")
        
        do {
            let fetchedItems:[TmdbTvEpisode] = try MoobeezManager.tempDataContex!.fetch(fetchRequest) as! [TmdbTvEpisode]
            
            for item in fetchedItems {
                links[item.tmdbId] = item.objectID.uriRepresentation()
            }
            
        } catch {
            fatalError("Failed to fetch episodes: \(error)")
        }
    }
    
    static func fetchMovieWithId(_ tmdbId:Int64) -> TmdbTvEpisode? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TmdbTvSeason")
        fetchRequest.predicate = NSPredicate(format: "tmdbId == %ld", tmdbId)
        
        do {
            let fetchedItems:[TmdbTvEpisode] = try MoobeezManager.tempDataContex!.fetch(fetchRequest) as! [TmdbTvEpisode]
            
            if fetchedItems.count > 0 {
                return fetchedItems[0]
            }
            
        } catch {
            fatalError("Failed to fetch episodes: \(error)")
        }
        
        return nil
    }
    
    func addEntriesFrom(tmdbDictionary: [String : Any]) {
        
        if let value = tmdbDictionary["id"] {
            tmdbId = (value as! NSNumber).int64Value
        }
        
        if let value = tmdbDictionary["episode_number"] {
            episodeNumber = (value as! NSNumber).int16Value
        }
        
        if let value = tmdbDictionary["name"] {
            if value is String {
                name = value as? String
            }
        }
        
        if let value = tmdbDictionary["air_date"] {
            if value is String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                date = dateFormatter.date(from: value as! String)
            }
        }
    }
}
