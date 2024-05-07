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
    
    private override init() {
        super.init()
        
        if !FileManager.default.fileExists(atPath: URL.moobeezDirectory.path(), isDirectory: nil) {
            try? FileManager.default.createDirectory(at: URL.moobeezDirectory, withIntermediateDirectories: true)
        }

        if !FileManager.default.fileExists(atPath: URL.teebeezDirectory.path(), isDirectory: nil) {
            try? FileManager.default.createDirectory(at: URL.teebeezDirectory, withIntermediateDirectories: true)
        }

    }
    
    var moobeez: [Moobee] = []
    
    var teebeez: [Teebee] = []
    
    public func save () {
        
    }
    
    public func load () {
        
        if let enumerator = FileManager.default.enumerator(at: URL.moobeezDirectory, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let moobee = try JSONDecoder().decode(Moobee.self, from: data)
                    moobeez.append(moobee)
                } catch { print(error, fileURL) }
            }
        }
        
        if let enumerator = FileManager.default.enumerator(at: URL.teebeezDirectory, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let teebee = try JSONDecoder().decode(Teebee.self, from: data)
                    for season in teebee.seasons {
                        season.teebee = teebee
                        for episode in season.episodes {
                            episode.season = season
                        }
                    }
                    teebeez.append(teebee)
                } catch { print(error, fileURL) }
            }
        }
        
        
        NotificationCenter.default.addObserver(forName: .TeebeezDidChangeNotification, object: nil, queue: nil) { (_) in
#if MAIN
            UIApplication.shared.applicationIconBadgeNumber = self.showsNotWatched
#endif
        }
    }
    
    // MARK: - Delete temp data
    
    func deleteTempData () {
        
        save()
    }
}

extension MoobeezManager {
    
    func addMoobee(_ moobee:Moobee, temporary: Bool = false) {
        moobeez.append(moobee)
        if !temporary {
            moobee.save()
        }
        
        NotificationCenter.default.post(name: .MoobeezDidChangeNotification, object: moobee.tmdbId)
        NotificationCenter.default.post(name: .BeeDidChangeNotification, object: moobee.tmdbId)
        
    }
    
    func removeMoobee(_ moobee:Moobee) {
        moobeez.removeAll { m in m.id == moobee.id }
        moobee.delete()
        NotificationCenter.default.post(name: .MoobeezDidChangeNotification, object: moobee.tmdbId)
        NotificationCenter.default.post(name: .BeeDidChangeNotification, object: moobee.tmdbId)
    }
    
    func addTeebee(_ teebee:Teebee, temporary: Bool = false) {
        
        teebeez.append(teebee)
        teebee.temporary = temporary
        if !temporary {
            teebee.save()
        }
        
        NotificationCenter.default.post(name: .TeebeezDidChangeNotification, object: teebee.tmdbId)
        NotificationCenter.default.post(name: .BeeDidChangeNotification, object: teebee.tmdbId)
    }
    
    func removeTeebee(_ teebee:Teebee) {
        teebeez.removeAll { t in t.id == teebee.id }
        teebee.delete()
        
        NotificationCenter.default.post(name: .TeebeezDidChangeNotification, object: teebee.tmdbId)
        NotificationCenter.default.post(name: .BeeDidChangeNotification, object: teebee.tmdbId)
    }
    
}

extension MoobeezManager {
    
    func loadTimelineItems() -> [(Date, [TimelineItem])] {
        
        let today = Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: (SettingsManager.shared.addExtraDay ? -24 * 3600 : 0)))
        //        let tommorow = today.addingTimeInterval(24 * 3600)
        
        var items = [TimelineItem]()
        
        let moobeez:[Moobee] = self.moobeez.filter({ moobee in
            return moobee.type == .seen || (moobee.type == .watchlist && moobee.releaseDate?.compare(today) == .orderedDescending)
        }).sorted(by: { m1, m2 in
            return m1.date!.compare(m2.date!) == .orderedDescending
        })
        
        for moobee in moobeez {
            items.append(TimelineItem(moobee:moobee))
        }
        
        var episodes:[Teebee.Episode] = teebeez.flatMap { teebee in
            return teebee.episodesBetween(startDate: today)
        }
        
        episodes.sort { e1, e2 in
            return e1.releaseDate!.compare(e2.releaseDate!) == .orderedAscending
        }
        
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
        
        let moobeez:[Moobee] = self.moobeez.filter({ moobee in
            return moobee.type == .watchlist && moobee.releaseDate?.compare(today) == .orderedAscending
        }).sorted(by: { m1, m2 in
            return m1.date!.compare(m2.date!) == .orderedDescending
        })
        
        for moobee in moobeez {
            items.append(TimelineItem(moobee:moobee))
        }
        
        var episodes:[Teebee.Episode] = teebeez.flatMap { teebee in
            return teebee.episodesBetween(endDate: today)
        }
        
        episodes.sort { e1, e2 in
            return e1.releaseDate!.compare(e2.releaseDate!) == .orderedAscending
        }
        
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
            
            var count = 0;
            
            for teebee in teebeez {
                count += teebee.notWatchedEpisodesCount
            }
            
            return count
        }
    }
    
    var showsNotWatched:Int {
        get {
            
            var count = 0;
            
            for teebee in teebeez {
                count += teebee.notWatchedEpisodesCount > 0 ? 1 : 0
            }
            
            return count
        }
    }
    
}

extension URL {
    
    static var documentsDirectory: URL {
        get {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
    }
    
    static var moobeezDirectory: URL {
        get {
            return documentsDirectory.appending(path: "Moobeez")
        }
    }
    
    static var teebeezDirectory: URL {
        get {
            return documentsDirectory.appending(path: "Teebeez")
        }
    }
    
}
