//
//  Tmdb.Person.swift
//  Moobeez
//
//  Created by Radu Banea on 03/10/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import Foundation
import CoreData

extension Tmdb {
    
    class Person: Codable {
        
        var id: String = ""
        
        var imdbId: String?
        
        var name: String = ""
        
        var overview: String?
        
        var profilePath: String?
        
        var popularity: Float = 0
        
        var charactersIds: Set<String> = []
        
        var profileImages: [Image] = []
        
        enum CodingKeys: String, CodingKey {
            case id
            case imdbId
            case name
            case overview
            case profilePath
            case popularity
            case charactersIds
            case profileImages
        }
        
        init (tmdbDictionary: [String : Any]) {
            addEntriesFrom(tmdbDictionary: tmdbDictionary)
            People[id] = self
        }
        
        func addEntriesFrom(tmdbDictionary: [String : Any]) {
            
            id = (tmdbDictionary["id"] as? NSNumber)?.stringValue ?? UUID().uuidString
            
            name = tmdbDictionary["name"] as? String ?? ""
            
            overview = tmdbDictionary["biography"] as? String ?? ""
            
            profilePath = tmdbDictionary["profile_path"] as? String ?? ""
            
            if let casts = tmdbDictionary["combined_credits"] {
                if casts is Dictionary<String, Any> {
                    if let cast = (casts as! Dictionary<String, Any>)["cast"] {
                        if cast is Array<Dictionary<String, Any>> {
                            
                            for characterDictionary:Dictionary<String, Any> in (cast as! Array) {
                                
                                if let id = (characterDictionary["id"] as? NSNumber)?.stringValue {
                                    if let character = characters.first(where: { character in
                                        character.id == id
                                    }) {
                                        character.addEntriesFrom(tmdbDictionary: characterDictionary)
                                        continue
                                    }
                                }
                                
                                let character:Character = character(characterDictionary)
                                
                                addToCharacters(character)
                                
                                if character.movie == nil {
                                    if (characterDictionary["media_type"] as! String) == "movie" {
                                        let movie = movie(characterDictionary)
                                        movie.addToCharacters(character)
                                    }
                                    else
                                    {
                                        let tvShow = tvShow(characterDictionary)
                                        tvShow.addToCharacters(character)
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
            
            if let images = tmdbDictionary["images"] {
                if images is Dictionary<String, Any> {
                    if let profiles = (images as! Dictionary<String, Any>)["profiles"] {
                        if profiles is Array<Dictionary<String, Any>> {
                            for imageDictionary:Dictionary<String, Any> in (profiles as! Array) {
                                
                                let image:Image = Image(tmdbDictionary: imageDictionary)
                                
                                profileImages.append(image)
                            }
                        }
                    }
                }
            }
            
            if let value = tmdbDictionary["imdb_id"] {
                if value is String {
                    imdbId = value as? String
                }
            }
            
            if let value = tmdbDictionary["popularity"] {
                if value is NSNumber {
                    popularity = ((value as? NSNumber)?.floatValue)!
                }
            }
        }
        
        func addToCharacters(_ character: Character) {
            character.person = self
            
            charactersIds.insert(character.id)
        }
        
        var characters: [Character] {
            get {
                charactersIds.compactMap { id in Characters[id] }
            }
        }
    }
}
