//
//  Tmdb.swift
//  Moobeez
//
//  Created by Mobilauch Labs on 29.03.2024.
//  Copyright © 2024 Gogo's Lab. All rights reserved.
//

import Foundation

class Tmdb {
    
    static var Movies: [String : Movie] = [:]
    static var TvShows: [String : TvShow] = [:]
    static var Characters: [String : Character] = [:]
    static var People: [String : Person] = [:]
    

    static func movie(_ dictionary: [String : Any]) -> Movie {
        if let id = dictionary["id"] as? String, let movie = Movies[id] {
            return movie
        }
        
        return Movie(tmdbDictionary: dictionary)
    }

    static func tvShow(_ dictionary: [String : Any]) -> TvShow {
        if let id = dictionary["id"] as? String, let tvShow = TvShows[id] {
            return tvShow
        }
        
        return TvShow(tmdbDictionary: dictionary)
    }

    static func character(_ dictionary: [String : Any]) -> Character {
        if let id = dictionary["id"] as? String, let character = Characters[id] {
            character.addEntriesFrom(tmdbDictionary: dictionary)
            return character
        }
        
        return Character(tmdbDictionary: dictionary)
    }

    static func person(_ dictionary: [String : Any]) -> Person {
        if let id = dictionary["id"] as? String, let person = People[id] {
            return person
        }
        
        return Person(tmdbDictionary: dictionary)
    }

}
