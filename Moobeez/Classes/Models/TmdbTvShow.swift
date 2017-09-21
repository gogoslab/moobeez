//
//  TmdbTvShow.swift
//  Moobeez
//
//  Created by Radu Banea on 09/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import CoreData

extension TmdbTvShow {
    
    func seasonWithNumber(number:Int16) -> TmdbTvSeason
    {
        if seasons != nil {
            for season:TmdbTvSeason in seasons?.array as! [TmdbTvSeason]
            {
                if (season.seasonNumber == number)
                {
                    return season
                }
            }
        }
        
        let season:TmdbTvSeason = NSEntityDescription.insertNewObject(forEntityName: "TmdbTvSeason", into: MoobeezManager.shared.persistentContainer.viewContext) as! TmdbTvSeason
        
        season.seasonNumber = number
        season.tvShow = self

        addToSeasons(season)
        
        return season
    }
    
}
