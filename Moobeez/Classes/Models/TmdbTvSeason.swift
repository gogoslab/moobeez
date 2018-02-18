//
//  TmdbTvSeason.swift
//  Moobeez
//
//  Created by Radu Banea on 09/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import CoreData

extension TmdbTvSeason {
    
    static var links:[Int64 : URL] = [Int64 : URL]()
    
    static func create(tmdbDictionary: [String : Any], insert:Bool = true) -> TmdbTvSeason {
        
        var season:TmdbTvSeason? = nil
        
        if let value = tmdbDictionary["id"] {
            let tmdbId = (value as! NSNumber).int64Value
            season = seasonWithId(tmdbId)
        }
        
        if season == nil {
            season = TmdbTvSeason.init(entity: NSEntityDescription.entity(forEntityName: "TmdbTvSeason", in: MoobeezManager.tempDataContex!)!, insertInto: insert ? MoobeezManager.tempDataContex : nil)
        }
        
        season!.addEntriesFrom(tmdbDictionary: tmdbDictionary)
        
        if (insert) {
            links[season!.tmdbId] = season?.objectID.uriRepresentation()
        }
        
        return season!
    }
    
    static func seasonWithId(_ tmdbId:Int64) -> TmdbTvSeason? {
        
        guard links[tmdbId] != nil else {
            return nil
        }
        
        let season = MoobeezManager.tempDataContex!.object(with: (MoobeezManager.tempDataContex!.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: links[tmdbId]!))!) as! TmdbTvSeason
        
        return season
        
    }
    
    static func updateLinks() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TmdbTvSeason")
        
        do {
            let fetchedItems:[TmdbTvSeason] = try MoobeezManager.tempDataContex!.fetch(fetchRequest) as! [TmdbTvSeason]
            
            for item in fetchedItems {
                links[item.tmdbId] = item.objectID.uriRepresentation()
            }
            
        } catch {
            fatalError("Failed to fetch seasons: \(error)")
        }
    }
    
    static func fetchMovieWithId(_ tmdbId:Int64) -> TmdbTvSeason? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TmdbTvSeason")
        fetchRequest.predicate = NSPredicate(format: "tmdbId == %ld", tmdbId)
        
        do {
            let fetchedItems:[TmdbTvSeason] = try MoobeezManager.tempDataContex!.fetch(fetchRequest) as! [TmdbTvSeason]
            
            if fetchedItems.count > 0 {
                return fetchedItems[0]
            }
            
        } catch {
            fatalError("Failed to fetch seasons: \(error)")
        }
        
        return nil
    }
    
    func addEntriesFrom(tmdbDictionary: [String : Any]) {
        
        if let value = tmdbDictionary["id"] {
            tmdbId = (value as! NSNumber).int64Value
        }
        
        if let value = tmdbDictionary["season_number"] {
            seasonNumber = (value as! NSNumber).int16Value
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
                    let episode:TmdbTvEpisode = TmdbTvEpisode.create(tmdbDictionary: episodeDictionary)
                    
                    if episode.season == nil {
                        addToEpisodes(episode)
                    }
                    episode.season = self
                    
                }
            }
        }
    }
    
    func episodeWithNumber(number:Int16) -> TmdbTvEpisode
    {
        if episodes != nil {
            for episode:TmdbTvEpisode in episodes?.array as! [TmdbTvEpisode]
            {
                if (episode.episodeNumber == number)
                {
                    return episode
                }
            }
        }
        
        let episode:TmdbTvEpisode = NSEntityDescription.insertNewObject(forEntityName: "TmdbTvEpisode", into: MoobeezManager.shared.tempContainer.viewContext) as! TmdbTvEpisode
        
        episode.episodeNumber = number
        episode.season = self
        
        addToEpisodes(episode)
        
        return episode
    }
    
}
