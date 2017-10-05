//
//  TmdbImage.swift
//  Moobeez
//
//  Created by Radu Banea on 04/10/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import CoreData

extension TmdbImage {
    
    static func create(tmdbDictionary: [String : Any], insert:Bool = true) -> TmdbImage {
        
        var image:TmdbImage? = nil
        
        if let value = tmdbDictionary["file_path"] {
            let path = value as! String
            image = imageWithPath(path)
        }
        
        if image == nil {
            image = TmdbImage.init(entity: NSEntityDescription.entity(forEntityName: "TmdbImage", in: MoobeezManager.coreDataContex!)!, insertInto: insert ? MoobeezManager.coreDataContex : nil)
        }
        
        image!.addEntriesFrom(tmdbDictionary: tmdbDictionary)
        
        return image!
    }
    
    static func imageWithPath(_ path:String) -> TmdbImage? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TmdbImage")
        fetchRequest.predicate = NSPredicate(format: "path == %@", path)
        
        do {
            let fetchedItems:[TmdbImage] = try MoobeezManager.coreDataContex!.fetch(fetchRequest) as! [TmdbImage]
            
            if fetchedItems.count > 0 {
                return fetchedItems[0]
            }
            
        } catch {
            fatalError("Failed to fetch images: \(error)")
        }
        
        return nil
    }
    
    func addEntriesFrom(tmdbDictionary: [String : Any]) {
        
        if let value = tmdbDictionary["file_path"] {
            if value is String {
                path = value as? String
            }
        }
        
        if let value = tmdbDictionary["aspect_ratio"] {
            if value is NSNumber {
                aspectRatio = ((value as? NSNumber)?.floatValue)!
            }
        }
    }
}
