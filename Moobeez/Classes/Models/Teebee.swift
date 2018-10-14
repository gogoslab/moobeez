//
//  Teebee.swift
//  Teebeez
//
//  Created by Radu Banea on 21/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import CoreData

extension Teebee {
    
    static func fetchTeebeeWithTmdbId(_ tmdbId:Int64) -> Teebee? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Teebee")
        fetchRequest.predicate = NSPredicate(format: "tmdbId == %ld", tmdbId)
        
        do {
            let fetchedItems:[Teebee] = try MoobeezManager.coreDataContex!.fetch(fetchRequest) as! [Teebee]
            
            if fetchedItems.count > 0 {
                return fetchedItems[0]
            }
            
        } catch {
            fatalError("Failed to fetch moobeez: \(error)")
        }
        
        return nil
    }
    
    convenience init(tmdbTvShow tvShow:TmdbTvShow) {
        
        self.init(entity: NSEntityDescription.entity(forEntityName: "Teebee", in: MoobeezManager.coreDataContex!)!, insertInto: nil)
        
        self.tmdbId = tvShow.tmdbId
        self.name = tvShow.name
        self.rating = 2.5
        self.date = Date()
        self.posterPath = tvShow.posterPath
        self.backdropPath = tvShow.backdropPath
        
        for tmdbSeason:TmdbTvSeason in Array(tvShow.seasons!) as! [TmdbTvSeason] {
            let season = seasonWithNumber(number: tmdbSeason.seasonNumber)
            season.posterPath = tmdbSeason.posterPath
        }
    }
    
    var tvShow:TmdbTvShow? {
        get {
            return TmdbTvShow.fetchTvShowWithId(tmdbId)
        }
        set (tvShow) {
            tmdbId = (tvShow != nil ? tvShow!.tmdbId : nil)!
            
            if tvShow != nil
            {
                self.posterPath = tvShow!.posterPath
                self.backdropPath = tvShow!.backdropPath
                
                for tmdbSeason:TmdbTvSeason in Array(tvShow!.seasons!) as! [TmdbTvSeason] {
                    let season = seasonWithNumber(number: tmdbSeason.seasonNumber)
                    season.setTmdbSeason(tmdbSeason: tmdbSeason)
                }
            }
        }
    }
    
    func seasonWithNumber(number:Int16) -> TeebeeSeason
    {
        if seasons != nil {
            for season:TeebeeSeason in Array(seasons!) as! [TeebeeSeason]
            {
                if (season.number == number)
                {
                    return season
                }
            }
        }
        
        let season:TeebeeSeason = NSEntityDescription.insertNewObject(forEntityName: "TeebeeSeason", into: MoobeezManager.coreDataContex!) as! TeebeeSeason
        
        season.number = number
        season.teebee = self
        
        addToSeasons(season)
        
        return season
    }
    
    var watchedEpisodesCount: NSInteger
    {
        get {
            var episodesCount = 0
            
            guard seasons != nil else {
                return 0
            }
            
            for season in seasons! {
                
                guard season is TeebeeSeason else {
                    continue
                }
                
                episodesCount += (season as! TeebeeSeason).watchedEpisodesCount
            }
            
            return episodesCount
        }
    }
    
    var notWatchedEpisodesCount: NSInteger
    {
        get {
            var episodesCount = 0
            
            guard seasons != nil else {
                return 0
            }
            
            for season in seasons! {
                
                guard season is TeebeeSeason else {
                    continue
                }
                
                episodesCount += (season as! TeebeeSeason).notWatchedEpisodesCount
            }
            
            return episodesCount
        }
    }
    
    var nextEpisode: TeebeeEpisode?
    {
        get {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult> (entityName: "TeebeeEpisode")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "releaseDate", ascending: true)]
            fetchRequest.predicate = NSPredicate(format: "watched == 0 AND season.teebee == %@", self)
            
            do {
                let fetchedItems:[TeebeeEpisode] = try MoobeezManager.coreDataContex!.fetch(fetchRequest) as! [TeebeeEpisode]
                
                if fetchedItems.count > 0 {
                    return fetchedItems[0]
                }
                
            } catch {
                fatalError("Failed to fetch moobeez: \(error)")
            }
            
            return nil
        }
    }
}
