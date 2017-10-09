//
//  Moobee.swift
//  Moobeez
//
//  Created by Radu Banea on 21/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import CoreData

enum MoobeeType: Int16 {
    case none = 0;
    case watchlist = 1;
    case seen = 2;
    
    case all = 3;
    
    case new = 4;
    case discarded = 5;
}

extension Moobee {
    
    static func fetchMoobeeWithTmdbId(_ tmdbId:Int64) -> Moobee? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Moobee")
        fetchRequest.predicate = NSPredicate(format: "tmdbId == %ld", tmdbId)
        
        do {
            let fetchedItems:[Moobee] = try MoobeezManager.coreDataContex!.fetch(fetchRequest) as! [Moobee]
            
            if fetchedItems.count > 0 {
                return fetchedItems[0]
            }
            
        } catch {
            fatalError("Failed to fetch moobeez: \(error)")
        }
        
        return nil
    }
    
    convenience init(tmdbMovie movie:TmdbMovie) {
        
        self.init(entity: NSEntityDescription.entity(forEntityName: "Moobee", in: MoobeezManager.coreDataContex!)!, insertInto: nil)
        
        self.name = movie.name
        self.moobeeType = .new
        self.rating = 2.5
        self.date = Date()

        self.movie = movie
    }
    
    var moobeeType:MoobeeType {
        get {
            return MoobeeType(rawValue: type)!
        }
        set (moobeeType) {
            type = moobeeType.rawValue
        }
    }
    
    var movie:TmdbMovie? {
        get {
            return TmdbMovie.fetchMovieWithId(tmdbId)
        }
        set (movie) {
            
            guard movie != nil else {
                tmdbId = -1
                return
            }
            
            tmdbId = movie!.tmdbId
            posterPath = movie!.posterPath
            backdropPath = movie!.backdropPath
            releaseDate = movie!.releaseDate
            
            MoobeezManager.shared.save()
            
            NotificationCenter.default.post(name: .BeeDidChangeNotification, object: tmdbId)
        }
    }
}
