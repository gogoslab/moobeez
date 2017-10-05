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
    
    func loadFromSqlIfNeeded () {
        
        if UserDefaults.standard.bool(forKey: "didTransferSqlDatabase") {
            return
        }
        
        deleteTable(name: "Moobee")
        deleteTable(name: "TmdbMovie")
        
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
                moobee.tmdbId = (row["tmdbId"] as! NSNumber).int64Value
                moobee.type = (row["type"] as! NSNumber).int16Value
                moobee.isFavorite = (row["isFavorite"] as! NSNumber).boolValue
                
                let tmdbMovie:TmdbMovie = NSEntityDescription.insertNewObject(forEntityName: "TmdbMovie", into: persistentContainer.viewContext) as! TmdbMovie
                
                tmdbMovie.name = row["name"] as? String
                tmdbMovie.posterPath = row["posterPath"] as? String
                tmdbMovie.backdropPath = row["backdropPath"] as? String
                tmdbMovie.releaseDate = Date.init(timeIntervalSince1970: (row["releaseDate"] as! NSNumber).doubleValue)
                tmdbMovie.tmdbId = moobee.tmdbId
                
                moobee.movie = tmdbMovie
                tmdbMovie.moobee = moobee
                
                TmdbMovie.links[tmdbMovie.tmdbId] = tmdbMovie.objectID.uriRepresentation()
                
            }
            
            let teebeez = db.query(sql: "SELECT * FROM Teebeez")
            
            for row in teebeez {
                
                let teebee:Teebee = NSEntityDescription.insertNewObject(forEntityName: "Teebee", into: persistentContainer.viewContext) as! Teebee
                
                teebee.name = row["name"] as? String
                teebee.rating = (row["rating"] as! NSNumber).floatValue
                teebee.date = Date.init(timeIntervalSince1970: (row["date"] as! NSNumber).doubleValue)
                teebee.tmdbId = (row["tmdbId"] as! NSNumber).int64Value
                teebee.lastUpdate = Date.init(timeIntervalSince1970: (row["lastUpdate"] as! NSNumber).doubleValue)

                let tmdbTvShow:TmdbTvShow = NSEntityDescription.insertNewObject(forEntityName: "TmdbTvShow", into: persistentContainer.viewContext) as! TmdbTvShow
                
                tmdbTvShow.name = row["name"] as? String
                tmdbTvShow.posterPath = row["posterPath"] as? String
                tmdbTvShow.backdropPath = row["backdropPath"] as? String
                tmdbTvShow.ended = (row["ended"] as! NSNumber).boolValue
                tmdbTvShow.tmdbId = teebee.tmdbId
                
                teebee.tvShow = tmdbTvShow
                tmdbTvShow.teebee = teebee
                
                let oldTeebeeId = (row["ID"] as! NSNumber).int64Value
                
                let episodes = db.query(sql: "SELECT * FROM Episodes WHERE teebeeId = \(oldTeebeeId)")
                
                for rowEpisode in episodes {
                    
                    let teebeeEpisode:TeebeeEpisode = NSEntityDescription.insertNewObject(forEntityName: "TeebeeEpisode", into: persistentContainer.viewContext) as! TeebeeEpisode
                    
                    teebeeEpisode.teebee = teebee;
                    teebeeEpisode.watched = (rowEpisode["watched"] as! NSNumber).boolValue
                    
                    let tmdbTvSeason:TmdbTvSeason = tmdbTvShow.seasonWithNumber(number: (rowEpisode["seasonNumber"] as! NSNumber).int16Value)

                    let tmdbTvEpisode:TmdbTvEpisode = tmdbTvSeason.episodeWithNumber(number: (rowEpisode["episodeNumber"] as! NSNumber).int16Value)

                    tmdbTvEpisode.date = Date.init(timeIntervalSince1970: (rowEpisode["airDate"] as! NSNumber).doubleValue)

                    tmdbTvEpisode.teebeeEpisode = teebeeEpisode
                    teebeeEpisode.tvEpisode = tmdbTvEpisode
                }
            }
            
            save()
        }
        
//        UserDefaults.standard.set(true, forKey: "didTransferSqlDatabase")
//        UserDefaults.standard.synchronize()

    }
    
    public func save () {
        saveContext()
    }
    
    private func deleteTable(name:String)
    {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentContainer.viewContext.execute(batchDeleteRequest)
            
        } catch let error {
            print(error.localizedDescription)
            // Error Handling
        }
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
}


