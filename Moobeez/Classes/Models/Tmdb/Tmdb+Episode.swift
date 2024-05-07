//
//  Tmdb.Season.swift
//  Moobeez
//
//  Created by Radu Banea on 09/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import Foundation
import CoreData

extension Tmdb {
    
    class Episode: Codable {
        
        var id: String = ""
        
        var date: Date?
        
        var episodeNumber: Int = 1
        var name: String = ""
        
        var overview: String?
        
        var posterPath: String?
        
        var season: Season?
        
        enum CodingKeys: String, CodingKey {
            case id
            case date
            case episodeNumber
            case name
            case overview
            case posterPath
        }
        
        init(episodeNumber: Int) {
            self.episodeNumber = episodeNumber
        }
        
        init (tmdbDictionary: [String : Any]) {
            addEntriesFrom(tmdbDictionary: tmdbDictionary)
        }
        
        func addEntriesFrom(tmdbDictionary: [String : Any]) {
            
            if let value = tmdbDictionary["id"] {
                id = (value as! NSNumber).stringValue
            }
            
            if let value = tmdbDictionary["episode_number"] {
                episodeNumber = (value as! NSNumber).intValue
            }
            
            if let value = tmdbDictionary["name"] {
                name = value as? String ?? ""
            }
            
            if let value = tmdbDictionary["air_date"] {
                if value is String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    date = dateFormatter.date(from: value as! String)
                }
            }
        }
    }
}
