//
//  TmdbPerson.swift
//  Moobeez
//
//  Created by Radu Banea on 03/10/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import CoreData

extension TmdbPerson {
    
    static var links:[Int64 : URL] = [Int64 : URL]()
    
    static func create(tmdbDictionary: [String : Any], insert:Bool = true) -> TmdbPerson {
        
        var person:TmdbPerson? = nil
        
        if let value = tmdbDictionary["id"] {
            let personId = (value as! NSNumber).int64Value
            person = personWithId(personId)
        }
        
        if person == nil {
            person = TmdbPerson.init(entity: NSEntityDescription.entity(forEntityName: "TmdbPerson", in: MoobeezManager.shared.tmdbDatabase.context)!, insertInto: insert ? MoobeezManager.shared.tmdbDatabase.context : nil)
        }
        
        person!.addEntriesFrom(tmdbDictionary: tmdbDictionary)
        
        if (insert) {
            links[person!.personId] = person?.objectID.uriRepresentation()
        }
        
        return person!
    }
    
    static func personWithId(_ tmdbId:Int64) -> TmdbPerson? {
        
        guard links[tmdbId] != nil else {
            return nil
        }
        
        let person = MoobeezManager.shared.tmdbDatabase.context.object(with: (MoobeezManager.shared.tmdbDatabase.context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: links[tmdbId]!))!) as! TmdbPerson
        
        return person
    }
    
    static func updateLinks() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TmdbPerson")
        
        do {
            let fetchedItems:[TmdbPerson] = try MoobeezManager.shared.tmdbDatabase.context.fetch(fetchRequest) as! [TmdbPerson]
            
            for item in fetchedItems {
                links[item.personId] = item.objectID.uriRepresentation()
            }
            
        } catch {
            fatalError("Failed to fetch persons: \(error)")
        }
    }
    
    static func fetchPersonWithId(_ tmdbId:Int64) -> TmdbPerson? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TmdbPerson")
        fetchRequest.predicate = NSPredicate(format: "personId == %ld", tmdbId)
        
        do {
            let fetchedItems:[TmdbPerson] = try MoobeezManager.shared.tmdbDatabase.context.fetch(fetchRequest) as! [TmdbPerson]
            
            if fetchedItems.count > 0 {
                return fetchedItems[0]
            }
            
        } catch {
            fatalError("Failed to fetch persons: \(error)")
        }
        
        return nil
    }
    
    func addEntriesFrom(tmdbDictionary: [String : Any]) {
        
        if let value = tmdbDictionary["id"] {
            personId = (value as! NSNumber).int64Value
        }
        
        if let value = tmdbDictionary["name"] {
            if value is String {
                name = value as? String
            }
        }
        
        if let value = tmdbDictionary["biography"] {
            if value is String {
                overview = value as? String
            }
        }
        
        if let value = tmdbDictionary["profile_path"] {
            if value is String {
                profilePath = value as? String
            }
        }


        if let casts = tmdbDictionary["combined_credits"] {
            if casts is Dictionary<String, Any> {
                if let cast = (casts as! Dictionary<String, Any>)["cast"] {
                    if cast is Array<Dictionary<String, Any>> {
                        
                        for characterDictionary:Dictionary<String, Any> in (cast as! Array) {
                            
                            let character:TmdbCharacter = TmdbCharacter.create(tmdbDictionary: characterDictionary)
                            
                            if character.person == nil {
                                character.person = self
                                addToCharacters(character)
                            }
                            
                            if character.movie == nil {
                                if (characterDictionary["media_type"] as! String) == "movie" {
                                    let movie:TmdbMovie = TmdbMovie.create(tmdbDictionary: characterDictionary)
                                    movie.addToCharacters(character)
                                    character.movie = movie
                                }
                                else
                                {
                                    let tvShow:TmdbTvShow = TmdbTvShow.create(tmdbDictionary: characterDictionary)
                                    tvShow.addToCharacters(character)
                                    character.movie = tvShow
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
                            
                            let image:TmdbImage = TmdbImage.create(tmdbDictionary: imageDictionary)
                            
                            addToProfileImages(image)
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
}
