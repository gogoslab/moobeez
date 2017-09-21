//
//  TmdbTvMovie.swift
//  Moobeez
//
//  Created by Radu Banea on 11/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import CoreData

extension TmdbMovie {
    
    static func create(tmdbDictionary: [String : Any]) -> TmdbMovie {
        
        let movie = TmdbMovie.init(entity: NSEntityDescription.entity(forEntityName: "TmdbMovie", in: MoobeezManager.coreDataContex!)!, insertInto: nil)
        
        movie.addEntriesFrom(tmdbDictionary: tmdbDictionary)
        
        return movie
    }
    
    func addEntriesFrom(tmdbDictionary: [String : Any]) {
        
        if let id = tmdbDictionary["id"] {
            tmdbId = (id as! NSNumber).int64Value
        }
        
        if let value = tmdbDictionary["title"] {
            if value is String {
                name = value as? String
            }
        }
        
        if let value = tmdbDictionary["overview"] {
            if value is String {
                overview = value as? String
            }
        }
        
    }
    
}
