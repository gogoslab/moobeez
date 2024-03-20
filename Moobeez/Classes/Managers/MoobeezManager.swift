//
//  MoobeezManager.swift
//  Moobeez
//
//  Created by Radu Banea on 08/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import UIKit
import CoreData


class MoobeezManager: NSObject {

    static let shared:MoobeezManager = MoobeezManager()
    
    var moobeezDatabase = Database(databaseName: "Moobeez")
    var tmdbDatabase = Database(databaseName: "Tmdb")
    
    private override init() {
        super.init()
    }
    
    
    public func save () {
        moobeezDatabase.saveContext()
    }
    
    public func load () {
        
        deleteTempData()
        TmdbMovie.updateLinks()
        TmdbTvShow.updateLinks()
        
        NotificationCenter.default.addObserver(forName: .TeebeezDidChangeNotification, object: nil, queue: nil) { (_) in
            #if MAIN
            UIApplication.shared.applicationIconBadgeNumber = self.showsNotWatched
            #endif
        }
    }
    
    // MARK: - Delete temp data
    
    func deleteTempData () {
        
        let moobeez:[Moobee] = moobeezDatabase.fetch(predicate: NSPredicate(format: "type == %ld", MoobeeType.new.rawValue))
        
        for moobee in moobeez {
            moobee.managedObjectContext?.delete(moobee)
        }
        
        let teebeez:[Teebee] = moobeezDatabase.fetch(predicate: NSPredicate(format: "temporary == true"))
        
        for teebee in teebeez {
            teebee.managedObjectContext?.delete(teebee)
            if let seasons = teebee.seasons?.array as? [TeebeeSeason] {
                for season in seasons {
                    season.managedObjectContext?.delete(season)
                    if let episodes = season.episodes?.array as? [TeebeeEpisode] {
                        for episode in episodes {
                            episode.managedObjectContext?.delete(episode)
                        }
                    }
                }
            }
        }

        save()
    }
}

extension MoobeezManager {
    
    func addMoobee(_ moobee:Moobee) {
        if moobee.managedObjectContext == nil {
            moobeezDatabase.context.insert(moobee)
            save()
            NotificationCenter.default.post(name: .MoobeezDidChangeNotification, object: moobee.tmdbId)
            NotificationCenter.default.post(name: .BeeDidChangeNotification, object: moobee.tmdbId)
        }
    }
    
    func removeMoobee(_ moobee:Moobee) {
        if moobee.managedObjectContext != nil {
            moobeezDatabase.context.delete(moobee)
            save()
            NotificationCenter.default.post(name: .MoobeezDidChangeNotification, object: moobee.tmdbId)
            NotificationCenter.default.post(name: .BeeDidChangeNotification, object: moobee.tmdbId)
        }
    }
    
    func addTeebee(_ teebee:Teebee) {
        if teebee.managedObjectContext == nil {
            moobeezDatabase.context.insert(teebee)
        }
        teebee.temporary = false
        save()
        NotificationCenter.default.post(name: .TeebeezDidChangeNotification, object: teebee.tmdbId)
        NotificationCenter.default.post(name: .BeeDidChangeNotification, object: teebee.tmdbId)
    }
    
    func removeTeebee(_ teebee:Teebee) {
        teebee.temporary = true
        save()
        NotificationCenter.default.post(name: .TeebeezDidChangeNotification, object: teebee.tmdbId)
        NotificationCenter.default.post(name: .BeeDidChangeNotification, object: teebee.tmdbId)
    }
    
}

extension MoobeezManager {
    
    func loadTimelineItems() -> [(Date, [TimelineItem])] {
    
        let today = Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: (SettingsManager.shared.addExtraDay ? -24 * 3600 : 0)))
//        let tommorow = today.addingTimeInterval(24 * 3600)
        
        var items = [TimelineItem]()
        
        let moobeez:[Moobee] = moobeezDatabase.fetch(predicate: NSPredicate(format: "type == %ld OR (type == %ld AND releaseDate >= %@)", MoobeeType.seen.rawValue, MoobeeType.watchlist.rawValue, today as CVarArg),
                                     sort:[NSSortDescriptor(key: "date", ascending: false)])
        
        for moobee in moobeez {
            items.append(TimelineItem(moobee:moobee))
        }

        let episodes:[TeebeeEpisode] = moobeezDatabase.fetch(predicate: NSPredicate(format: "watched == 0 AND releaseDate >= %@", today as CVarArg), sort: [NSSortDescriptor(key: "releaseDate", ascending: true)])
        
        for episode in episodes {
            items.append(TimelineItem(episode:episode))
        }
        
        let dictionary: [Date : [TimelineItem]] = Dictionary(grouping: items, by: { $0.date!})
        
        var grouppedItems = dictionary.sorted(by: { $0.0 < $1.0 })
        
        grouppedItems.sort { (group1, group2) -> Bool in
            return group1.key < group2.key
        }
        
        return grouppedItems
    }
    
    func loadDashboardItems() -> [(Date, [TimelineItem])] {
        
        let today = Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: (SettingsManager.shared.addExtraDay ? -24 * 3600 : 0)))
        //        let tommorow = today.addingTimeInterval(24 * 3600)
        
        var items = [TimelineItem]()
        
        let moobeez:[Moobee] = moobeezDatabase.fetch(predicate: NSPredicate(format: "type == %ld AND releaseDate < %@", MoobeeType.watchlist.rawValue, today as CVarArg), sort: [NSSortDescriptor(key: "date", ascending: false)])

        for moobee in moobeez {
            items.append(TimelineItem(moobee:moobee))
        }
        
        let episodes:[TeebeeEpisode] = moobeezDatabase.fetch(predicate: NSPredicate(format: "watched == 0 AND releaseDate < %@", today as CVarArg), sort: [NSSortDescriptor(key: "releaseDate", ascending: true), NSSortDescriptor(key: "number", ascending: true)])
        
        for episode in episodes {
            items.append(TimelineItem(episode:episode))
        }
        let dictionary: [Date : [TimelineItem]] = Dictionary(grouping: items, by: { $0.date!})
        
        var grouppedItems = dictionary.sorted(by: { $0.0 < $1.0 })
        
        grouppedItems.sort { (group1, group2) -> Bool in
            return group1.key < group2.key
        }
        
        return grouppedItems
    }
    
}

extension MoobeezManager {
    
    var episodesNotWatched:Int {
        get {
            
            let today = Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: (SettingsManager.shared.addExtraDay ? -24 * 3600 : 0)))
            let tommorow = today.addingTimeInterval(24 * 3600)
        
            let predicate = NSPredicate(format: "watched == 0 AND releaseDate < %@ AND releaseDate.timeIntervalSince1970 > 100 AND season.teebee.temporary == false", argumentArray: [tommorow])

            let episodes: [TeebeeEpisode] = moobeezDatabase.fetch(predicate: predicate)
            
            return episodes.count
        }
    }
    
    var showsNotWatched:Int {
        get {
            
            let today = Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: (SettingsManager.shared.addExtraDay ? -24 * 3600 : 0)))
            let tommorow = today.addingTimeInterval(24 * 3600)
            
            let predicate = NSPredicate(format: "temporary == false && isFavorite == true")
            
            var teebeez: [Teebee] = moobeezDatabase.fetch(predicate: predicate)
            
            teebeez = teebeez.filter { $0.nextEpisode?.releaseDate != nil && ($0.nextEpisode?.releaseDate)! < tommorow && ($0.nextEpisode?.releaseDate)!.timeIntervalSince1970 > 100 }
            
            return teebeez.count
        }
    }
    
}
