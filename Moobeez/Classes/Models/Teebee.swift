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
    
    convenience init(tmdbTvShow tvShow:TmdbTvShow) {
        
        self.init(entity: NSEntityDescription.entity(forEntityName: "Teebee", in: MoobeezManager.coreDataContex!)!, insertInto: nil)
        
        self.tmdbId = tvShow.tmdbId
        self.name = tvShow.name
        self.rating = 2.5
        self.date = Date()
        self.posterPath = tvShow.posterPath
        self.backdropPath = tvShow.backdropPath
    }
    
    var tvShow:TmdbTvShow? {
        get {
            return TmdbTvShow.fetchTvShowWithId(tmdbId)
        }
        set (tvShow) {
            tmdbId = (tvShow != nil ? tvShow!.tmdbId : nil)!
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
}
