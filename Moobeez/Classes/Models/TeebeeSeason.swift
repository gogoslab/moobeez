//
//  TeebeeSeason.swift
//  Moobeez
//
//  Created by Radu Banea on 09/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import Foundation
import CoreData

extension TeebeeSeason {
    
    func episodeWithNumber(number:Int16) -> TeebeeEpisode
    {
        if episodes != nil {
            for episode:TeebeeEpisode in Array(episodes!) as! [TeebeeEpisode]
            {
                if (episode.number == number)
                {
                    return episode
                }
            }
        }
        
        let episode:TeebeeEpisode = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "TeebeeEpisode", in: MoobeezManager.shared.moobeezDatabase.context)!, insertInto: self.managedObjectContext) as! TeebeeEpisode

        episode.number = number
        episode.season = self
        episode.watched = false
        
        if teebee?.tmdbId != nil {
            episode.tmdbId = (teebee?.tmdbId)!
        }
        
        addToEpisodes(episode)
        
        return episode
    }
    
    func setTmdbSeason(tmdbSeason:TmdbTvSeason)
    {
        posterPath = tmdbSeason.posterPath
        number = tmdbSeason.seasonNumber
        
        for tmdbEpisode:TmdbTvEpisode in tmdbSeason.episodes?.array as! [TmdbTvEpisode]
        {
            let episode = episodeWithNumber(number: tmdbEpisode.episodeNumber)
            episode.releaseDate = tmdbEpisode.date
            episode.name = tmdbEpisode.name
        }
    }
    
    var pastEpisodes:[TeebeeEpisode] {
        get {
            return (episodes?.array as! [TeebeeEpisode]).filter { $0.watched == false
                && $0.releaseDate?.timeIntervalSince1970 ?? 0 > 100
                && $0.releaseDate?.timeIntervalSinceNow ?? 0 < 0 }
        }
    }
    
    var watchedEpisodesCount: NSInteger
    {
        get {
            guard episodes != nil else {
                return 0
            }
            
            return (episodes?.array as! [TeebeeEpisode]).filter { $0.watched == true && $0.releaseDate?.timeIntervalSince1970 ?? 0 > 100 }.count
        }
    }

    var notWatchedEpisodesCount: NSInteger
    {
        get {
            guard episodes != nil else {
                return 0
            }
            
            return (episodes?.array as! [TeebeeEpisode]).filter { $0.watched == false && $0.releaseDate?.timeIntervalSince1970 ?? 0 > 100 }.count
        }
    }
    
    var watched: Bool
    {
        get {
            return notWatchedEpisodesCount == 0
        }
        set {
            let pastEpisodes = self.pastEpisodes
            for episode in pastEpisodes {
                episode.watched = newValue
            }
        }
    }
    
    var tmdbId:String
    {
        get {
            return "\(teebee!.tmdbId)_\(number)"
        }
    }
}
