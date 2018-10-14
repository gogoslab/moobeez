//
//  MoobeezManager.swift
//  Moobeez
//
//  Created by Radu Banea on 08/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit
import CoreData


class MoobeezManager: NSObject {

    static let shared:MoobeezManager = MoobeezManager()
    
    private override init() {
        super.init()
    }
    
    func loadFromSqlIfNeeded () -> Bool {
        
        if UserDefaults.standard.bool(forKey: "didTransferSqlDatabase") {
            return false
        }
        
        deleteTable(name: "Moobee")
        deleteTable(name: "Teebee")
        deleteTable(name: "TeebeeEpisode")

        let db = SQLiteDB.shared
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "d M yyyy"
        let referenceDate:Date = dateFormatter.date(from: "1 1 2001")!
        
        if (db.openDB())
        {
            let moobeez = db.query(sql: "SELECT * FROM Moobeez")
            
            for row in moobeez {
                
                let moobee:Moobee = NSEntityDescription.insertNewObject(forEntityName: "Moobee", into: persistentContainer.viewContext) as! Moobee
                
                moobee.name = row["name"] as? String
                moobee.rating = (row["rating"] as! NSNumber).floatValue
                moobee.date = Date.init(timeInterval: (row["date"] as! NSNumber).doubleValue, since:referenceDate)
                moobee.type = (row["type"] as! NSNumber).int16Value
                moobee.isFavorite = (row["isFavorite"] as! NSNumber).boolValue

                moobee.tmdbId = (row["tmdbId"] as! NSNumber).int64Value
                moobee.posterPath = row["posterPath"] as? String
                moobee.backdropPath = row["backdropPath"] as? String
                moobee.releaseDate = Date.init(timeIntervalSince1970: (row["releaseDate"] as! NSNumber).doubleValue)

            }
            
            let teebeez = db.query(sql: "SELECT * FROM Teebeez")
            
            for row in teebeez {
                
                let teebee:Teebee = NSEntityDescription.insertNewObject(forEntityName: "Teebee", into: persistentContainer.viewContext) as! Teebee
                
                teebee.name = row["name"] as? String
                teebee.rating = (row["rating"] as! NSNumber).floatValue
                teebee.date = Date.init(timeIntervalSince1970: (row["date"] as! NSNumber).doubleValue)

                teebee.tmdbId = (row["tmdbId"] as! NSNumber).int64Value
                teebee.posterPath = row["posterPath"] as? String
                teebee.backdropPath = row["backdropPath"] as? String
                
                teebee.lastUpdate = Date.init(timeIntervalSince1970: (row["lastUpdate"] as! NSNumber).doubleValue)

                let oldTeebeeId = (row["ID"] as! NSNumber).int64Value
                
                let episodes = db.query(sql: "SELECT * FROM Episodes WHERE teebeeId = \(oldTeebeeId)")
                
                for rowEpisode in episodes {
                    let teebeeSeason:TeebeeSeason = teebee.seasonWithNumber(number: (rowEpisode["seasonNumber"] as! NSNumber).int16Value)
                    teebeeSeason.posterPath = ""
                    let teebeeEpisode:TeebeeEpisode = teebeeSeason.episodeWithNumber(number: (rowEpisode["episodeNumber"] as! NSNumber).int16Value)
                    
                    teebeeEpisode.watched = (rowEpisode["watched"] as! NSNumber).boolValue
                    teebeeEpisode.releaseDate = Date.init(timeIntervalSince1970: (rowEpisode["airDate"] as! NSNumber).doubleValue)
                }
            }
            
            save()
        }
        
        UserDefaults.standard.set(true, forKey: "didTransferSqlDatabase")
        UserDefaults.standard.synchronize()

        return true
    }
    
    public func save () {
        saveContext()
    }
    
    public func load () {
        
        guard loadFromSqlIfNeeded() == false else {
            return
        }
        
        deleteTempData()
        TmdbMovie.updateLinks()
        TmdbTvShow.updateLinks()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        
        let container = NSPersistentContainer(name: "Moobeez")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var tempContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        
        let container = NSPersistentContainer(name: "Tmdb")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    private func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static var coreDataContex:NSManagedObjectContext? {
        get {
            return MoobeezManager.shared.persistentContainer.viewContext
        }
    }
    
    static var tempDataContex:NSManagedObjectContext? {
        get {
            return MoobeezManager.shared.tempContainer.viewContext
        }
    }
    
    // MARK: - Delete temp data
    
    func deleteTempData () {
        
        let moobeezFetchRequest = NSFetchRequest<Moobee> (entityName: "Moobee")
        
        moobeezFetchRequest.predicate = NSPredicate(format: "type == %ld", MoobeeType.new.rawValue)
        
        do {
            let moobeez = try MoobeezManager.coreDataContex!.fetch(moobeezFetchRequest)
            
            for moobee in moobeez {
                moobee.managedObjectContext?.delete(moobee)
            }
        }
        catch (_) {
            
        }
        
        save()
    }
    
    private func deleteTable(name:String, predicate:NSPredicate? = nil)
    {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        fetchRequest.predicate = predicate
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentContainer.viewContext.execute(batchDeleteRequest)
            
        } catch let error {
            print(error.localizedDescription)
            // Error Handling
        }
    }
}

extension MoobeezManager {
    
    func addMoobee(_ moobee:Moobee) {
        if moobee.managedObjectContext == nil {
            persistentContainer.viewContext.insert(moobee)
            save()
            NotificationCenter.default.post(name: .MoobeezDidChangeNotification, object: moobee.tmdbId)
            NotificationCenter.default.post(name: .BeeDidChangeNotification, object: moobee.tmdbId)
        }
    }
    
    func removeMoobee(_ moobee:Moobee) {
        if moobee.managedObjectContext != nil {
            persistentContainer.viewContext.delete(moobee)
            save()
            NotificationCenter.default.post(name: .MoobeezDidChangeNotification, object: moobee.tmdbId)
            NotificationCenter.default.post(name: .BeeDidChangeNotification, object: moobee.tmdbId)
        }
    }
    
    func addTeebee(_ teebee:Teebee) {
        if teebee.managedObjectContext == nil {
            persistentContainer.viewContext.insert(teebee)
            save()
            NotificationCenter.default.post(name: .TeebeezDidChangeNotification, object: teebee.tmdbId)
            NotificationCenter.default.post(name: .BeeDidChangeNotification, object: teebee.tmdbId)
        }
    }
    
    func removeTeebee(_ teebee:Teebee) {
        if teebee.managedObjectContext != nil {
            persistentContainer.viewContext.delete(teebee)
            save()
            NotificationCenter.default.post(name: .TeebeezDidChangeNotification, object: teebee.tmdbId)
            NotificationCenter.default.post(name: .BeeDidChangeNotification, object: teebee.tmdbId)
        }
    }
    
}

extension MoobeezManager {
    
    func loadTimelineItems() -> [(Date, [TimelineItem])] {
    
        let today = Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: (SettingsManager.shared.addExtraDay ? -24 * 3600 : 0)))
//        let tommorow = today.addingTimeInterval(24 * 3600)
        
        var items = [TimelineItem]()
        
        let moobeezFetchRequest = NSFetchRequest<Moobee> (entityName: "Moobee")
        
        moobeezFetchRequest.predicate = NSPredicate(format: "type == %ld OR (type == %ld AND releaseDate >= %@)", MoobeeType.seen.rawValue, MoobeeType.watchlist.rawValue, today as CVarArg)
        
        moobeezFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let moobeez = try MoobeezManager.coreDataContex!.fetch(moobeezFetchRequest)
            
            for moobee in moobeez {
                items.append(TimelineItem(moobee:moobee))
            }
        }
        catch (_) {
            
        }
        
        let episodesFetchRequest = NSFetchRequest<TeebeeEpisode> (entityName: "TeebeeEpisode")
        episodesFetchRequest.sortDescriptors = [NSSortDescriptor(key: "releaseDate", ascending: true)]
        episodesFetchRequest.predicate = NSPredicate(format: "watched == 0 AND releaseDate >= %@", today as CVarArg)
        
        do {
            let episodes = try MoobeezManager.coreDataContex!.fetch(episodesFetchRequest)
            
            for episode in episodes {
                items.append(TimelineItem(episode:episode))
            }
        }
        catch (_) {
            
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
        
        let moobeezFetchRequest = NSFetchRequest<Moobee> (entityName: "Moobee")
        
        moobeezFetchRequest.predicate = NSPredicate(format: "type == %ld AND releaseDate < %@", MoobeeType.watchlist.rawValue, today as CVarArg)
        
        moobeezFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let moobeez = try MoobeezManager.coreDataContex!.fetch(moobeezFetchRequest)
            
            for moobee in moobeez {
                items.append(TimelineItem(moobee:moobee))
            }
        }
        catch (_) {
            
        }
        
        let episodesFetchRequest = NSFetchRequest<TeebeeEpisode> (entityName: "TeebeeEpisode")
        episodesFetchRequest.sortDescriptors = [NSSortDescriptor(key: "releaseDate", ascending: true)]
        episodesFetchRequest.predicate = NSPredicate(format: "watched == 0 AND releaseDate < %@", today as CVarArg)
        
        do {
            let episodes = try MoobeezManager.coreDataContex!.fetch(episodesFetchRequest)
            
            for episode in episodes {
                items.append(TimelineItem(episode:episode))
            }
        }
        catch (_) {
            
        }
        
        let dictionary: [Date : [TimelineItem]] = Dictionary(grouping: items, by: { $0.date!})
        
        var grouppedItems = dictionary.sorted(by: { $0.0 < $1.0 })
        
        grouppedItems.sort { (group1, group2) -> Bool in
            return group1.key < group2.key
        }
        
        return grouppedItems
    }
    
}
