//
//  Tmdb.Character.swift
//  Moobeez
//
//  Created by Radu Banea on 03/10/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import Foundation
import CoreData

extension Tmdb {
    
    class Character: Codable {
        
        var id: String = ""
        var name: String = ""
        
        var castId: Int = 0
        
        var movieId: String?
        var personId: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case movieId
            case personId
            case castId
        }
        
        init (tmdbDictionary: [String : Any]) {
            addEntriesFrom(tmdbDictionary: tmdbDictionary)
            Characters[id] = self
        }
        
        func addEntriesFrom(tmdbDictionary: [String : Any]) {
            
            id = tmdbDictionary["credit_id"] as? String ?? ""
            
            name = tmdbDictionary["character"] as? String ?? ""
            
            castId = tmdbDictionary["cast_id"] as? Int ?? 0
        }
        
        var movie: Item? {
            get {
                return Movies[movieId ?? ""]
            }
            set {
                movieId = newValue?.id
            }
        }
        
        var person: Person? {
            get {
                return People[personId ?? ""]
            }
            set {
                personId = newValue?.id
            }
        }
        
        
        
        var date:Date? {
            get {
                return movie?.releaseDate
            }
        }
    }
}
