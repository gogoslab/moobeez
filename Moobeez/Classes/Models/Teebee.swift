//
//  Teebee.swift
//  Teebeez
//
//  Created by Radu Banea on 21/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import Foundation
import CoreData

class Teebee: Bee, Identifiable, Equatable, Codable {
    
    static func == (lhs: Teebee, rhs: Teebee) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id = UUID()
    
    var name: String
    
    var date: Date?
    
    var posterPath: String?
    var backdropPath: String?
    var releaseDate: Date?
    var rating: Float = 5
    var tmdbId: String?
    
    var isFavorite: Bool = false

    var temporary: Bool = false    
    var lastUpdateDate: Date?
    
    var seasons: [Season] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case date
        case posterPath
        case backdropPath
        case releaseDate
        case rating
        case tmdbId
        
        case isFavorite
        case lastUpdateDate
        case temporary
        
        case seasons
    }
    
    init(tmdbTvShow tvShow:Tmdb.TvShow) {
        
        self.tmdbId = tvShow.id
        self.name = tvShow.name
        self.rating = 2.5
        self.date = Date()
        self.posterPath = tvShow.posterPath
        self.backdropPath = tvShow.backdropPath
        self.temporary = true
        
        for tmdbSeason:Tmdb.Season in tvShow.seasons {
            let season = seasonWithNumber(number: tmdbSeason.seasonNumber)
            season.posterPath = tmdbSeason.posterPath
        }
    }
    
}

extension Teebee {
    
    static func fetchTeebeeWithTmdbId(_ tmdbId: String) -> Teebee? {
        
        return MoobeezManager.shared.teebeez.first { teebee in
            teebee.tmdbId == tmdbId
        }
    }
    
    var tvShow:Tmdb.TvShow? {
        get {
            return tmdbId == nil ? nil : Tmdb.TvShows[tmdbId!]
        }
        set (tvShow) {
            guard let tvShow = tvShow else {
                tmdbId = nil
                return
            }
            tmdbId = tvShow.id
            
            self.posterPath = tvShow.posterPath
            self.backdropPath = tvShow.backdropPath
            
            for tmdbSeason:Tmdb.Season in tvShow.seasons {
                let season = seasonWithNumber(number: tmdbSeason.seasonNumber)
                season.setTmdbSeason(tmdbSeason: tmdbSeason)
            }
        }
    }
    
    func seasonWithNumber(number: Int) -> Season
    {
        for season:Season in seasons
        {
            if (season.number == number)
            {
                return season
            }
        }
        
        let season = Season()
        
        season.number = number
        season.teebee = self
        season.tmdbId = "\(tmdbId ?? "")_\(number)"
        
        seasons.append(season)
        
        return season
    }
    
    var watchedEpisodesCount: NSInteger
    {
        get {
            var episodesCount = 0
            
            for season in seasons {
                
                episodesCount += season.watchedEpisodesCount
            }
            
            return episodesCount
        }
    }
    
    var notWatchedEpisodesCount: NSInteger
    {
        get {
            var episodesCount = 0
            
            for season in seasons {
                
                episodesCount += season.pastEpisodes.count
            }
            
            return episodesCount
        }
    }
    
    var nextEpisode: Episode?
    {
        get {
            
            for season in seasons {
                for episode in season.episodes {
                    if episode.watched == false && episode.releaseDate != nil {
                        return episode
                    }
                }
            }
            
            return nil
        }
    }
    
    var notWatchedEpisodes: [Episode] {
        get {
            var notWatchedEpisodes: [Episode] = []
            
            for season in seasons {
                notWatchedEpisodes.append(contentsOf: season.pastEpisodes)
            }
            
            return notWatchedEpisodes
        }
    }
    
    var nextEpisodes: [Episode] {
        get {
            var nextEpisodes: [Episode] = []
            
            for season in seasons {
                nextEpisodes.append(contentsOf: season.nextEpisodes)
            }
            
            return nextEpisodes
        }
    }
    
    func markAsWatched() {
        for season in seasons {
            season.watched = true
        }
    }
    
    func episodesBetween(startDate: Date? = nil, endDate: Date? = nil) -> [Teebee.Episode] {
        
        return seasons.flatMap { season in
            return season.episodesBetween(startDate: startDate, endDate: endDate)
        }
    }
    
    public var description: String {
        get {
            return "\(self.name) - \(nextEpisode != nil ? "Next Ep: \(nextEpisode!)" : "")"
        }
    }
}

extension Teebee {
    
    var file: URL {
        get {
            return URL.teebeezDirectory.appendingPathComponent(id.uuidString)
        }
    }
    
    func save() {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            print("Writing...  📖: \(file.description)")
            try encoder.encode(self).write(to: file)
        } catch {
            print("Couldn’t save new entry to \(file), \(error.localizedDescription)")
        }
    }
    
    func delete() {
        
        do {
            try FileManager.default.removeItem(at: file)
        } catch {
            
        }
        
    }
    
}
