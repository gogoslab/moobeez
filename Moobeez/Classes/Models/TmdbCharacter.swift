//
//  TmdbCharacter.swift
//  Moobeez
//
//  Created by Radu Banea on 03/10/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import CoreData

extension TmdbCharacter {
    
    static var links:[String : URL] = [String : URL]()
    
    static func create(tmdbDictionary: [String : Any], insert:Bool = true) -> TmdbCharacter {
        
        var character:TmdbCharacter? = nil
        
        if let value = tmdbDictionary["credit_id"] {
            let characterId = value as! String
            character = characterWithId(characterId)
        }
        
        if character == nil {
            character = TmdbCharacter.init(entity: NSEntityDescription.entity(forEntityName: "TmdbCharacter", in: MoobeezManager.tempDataContex!)!, insertInto: insert ? MoobeezManager.tempDataContex : nil)
        }
        
        character!.addEntriesFrom(tmdbDictionary: tmdbDictionary)
        
        if (insert) {
            links[character!.characterId!] = character?.objectID.uriRepresentation()
        }
        
        return character!
    }
    
    static func characterWithId(_ tmdbId:String) -> TmdbCharacter? {
        
        guard links[tmdbId] != nil else {
            return nil
        }
        
        let character = MoobeezManager.tempDataContex!.object(with: (MoobeezManager.tempDataContex!.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: links[tmdbId]!))!) as! TmdbCharacter
        
        return character
    }
    
    static func updateLinks() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TmdbCharacter")
        
        do {
            let fetchedItems:[TmdbCharacter] = try MoobeezManager.tempDataContex!.fetch(fetchRequest) as! [TmdbCharacter]
            
            for item in fetchedItems {
                if item.characterId != nil {
                    links[(item.characterId)!] = item.objectID.uriRepresentation()
                }
            }
            
        } catch {
            fatalError("Failed to fetch characters: \(error)")
        }
    }
    
    static func fetchCharacterWithId(_ tmdbId:String) -> TmdbCharacter? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TmdbCharacter")
        fetchRequest.predicate = NSPredicate(format: "characterId == %@", tmdbId)
        
        do {
            let fetchedItems:[TmdbCharacter] = try MoobeezManager.tempDataContex!.fetch(fetchRequest) as! [TmdbCharacter]
            
            if fetchedItems.count > 0 {
                return fetchedItems[0]
            }
            
        } catch {
            fatalError("Failed to fetch characters: \(error)")
        }
        
        return nil
    }
    
    func addEntriesFrom(tmdbDictionary: [String : Any]) {
        
        if let value = tmdbDictionary["credit_id"] {
            if value is String {
                characterId = value as? String
            }
        }
        
        if let value = tmdbDictionary["character"] {
            if value is String {
                name = value as? String
            }
        }
        
    }
    
    var date:Date? {
        get {
            return movie?.releaseDate
        }
    }
}
