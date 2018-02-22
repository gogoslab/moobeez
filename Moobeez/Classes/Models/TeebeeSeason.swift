//
//  TeebeeSeason.swift
//  Moobeez
//
//  Created by Radu Banea on 09/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
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
        
        let episode:TeebeeEpisode = NSEntityDescription.insertNewObject(forEntityName: "TeebeeEpisode", into: MoobeezManager.coreDataContex!) as! TeebeeEpisode
        
        episode.number = number
        episode.season = self
        episode.teebee = teebee
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
    
    var watchedEpisodesCount: NSInteger
    {
        get {
            guard episodes != nil else {
                return 0
            }
            
            return (episodes?.filtered(using: NSPredicate(format: "watched == 1")).count)!
        }
    }

    var notWatchedEpisodesCount: NSInteger
    {
        get {
            guard episodes != nil else {
                return 0
            }
            
            return (episodes?.filtered(using: NSPredicate(format: "watched == 0")).count)!
        }
    }
    
    var tmdbId:String
    {
        get {
            return "\(teebee!.tmdbId)_\(number)"
        }
    }
}
