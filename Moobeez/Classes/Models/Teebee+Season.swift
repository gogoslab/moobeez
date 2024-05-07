//
//  Teebee.Season.swift
//  Moobeez
//
//  Created by Radu Banea on 09/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import Foundation
import CoreData

extension Teebee {

    class Season: Codable {
        
        var number: Int = 0
        var posterPath: String?
        
        var episodes: [Episode] = []
        
        var tmdbId: String?
        
        var teebee: Teebee?
        
        enum CodingKeys: String, CodingKey {
            case number
            case posterPath
            case tmdbId
            case episodes
        }
        
        init() {
        }
        
        func episodeWithNumber(number: Int) -> Episode
        {
            if let episode = episodes.first(where: { episode in
                episode.number == number
            }) {
                return episode
            }
            
            let episode = Episode()
            
            episode.number = number
            episode.season = self
            episode.watched = false
            
            if teebee?.tmdbId != nil {
                episode.tmdbId = (teebee?.tmdbId)!
            }
            
            addToEpisodes(episode)
            
            return episode
        }
        
        func setTmdbSeason(tmdbSeason:Tmdb.Season)
        {
            posterPath = tmdbSeason.posterPath
            number = tmdbSeason.seasonNumber
            
            for tmdbEpisode:Tmdb.Episode in tmdbSeason.episodes
            {
                let episode = episodeWithNumber(number: tmdbEpisode.episodeNumber)
                episode.releaseDate = tmdbEpisode.date
                episode.name = tmdbEpisode.name
            }
        }
        
        var pastEpisodes:[Episode] {
            get {
                return episodes.filter { $0.watched == false
                    && $0.releaseDate?.timeIntervalSince(.distantPast) ?? 0 > 100
                    && $0.releaseDate?.timeIntervalSinceNow ?? 0 < 0 }
            }
        }
        
        var nextEpisodes:[Episode] {
            get {
                return episodes.filter { $0.watched == false
                    && $0.releaseDate?.timeIntervalSince(.distantPast) ?? 0 > 100
                    && $0.releaseDate?.timeIntervalSinceNow ?? 0 >= 0 }
            }
        }
        
        var watchedEpisodesCount: NSInteger
        {
            get {
                return episodes.filter { $0.watched == true && $0.releaseDate?.timeIntervalSince(.distantPast) ?? 0 > 100 }.count
            }
        }
        
        var notWatchedEpisodesCount: NSInteger
        {
            get {
                return episodes.filter { $0.watched == false && $0.releaseDate?.timeIntervalSince(.distantPast) ?? 0 > 100 }.count
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
        
        func addToEpisodes(_ episode: Episode) {
            episode.season = self
            episodes.append(episode)
        }
        
        func episodesBetween(startDate: Date?, endDate: Date?) -> [Teebee.Episode] {
            return episodes.filter { $0.watched == false && $0.releaseDate != nil
                && $0.releaseDate!.timeIntervalSince(.distantPast) > 100
                && $0.releaseDate!.timeIntervalSince(startDate ?? .distantPast) >= 0
                && $0.releaseDate!.timeIntervalSince(endDate ?? .distantFuture) <= 0}
        }
    }
}
