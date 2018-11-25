//
//  TmdbImage.swift
//  Moobeez
//
//  Created by Radu Banea on 04/10/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import Foundation
import CoreData

extension TmdbImage {
    
    static var links:[String : URL] = [String : URL]()
    
    static func create(tmdbDictionary: [String : Any], insert:Bool = true) -> TmdbImage {
        
        var image:TmdbImage? = nil
        
        if let value = tmdbDictionary["file_path"] {
            let path = value as! String
            image = imageWithPath(path)
        }
        
        if image == nil {
            image = TmdbImage.init(entity: NSEntityDescription.entity(forEntityName: "TmdbImage", in: MoobeezManager.shared.tmdbDatabase.context)!, insertInto: insert ? MoobeezManager.shared.tmdbDatabase.context : nil)
        }
        
        image!.addEntriesFrom(tmdbDictionary: tmdbDictionary)
        
        if (insert) {
            links[image!.path!] = image?.objectID.uriRepresentation()
        }
        return image!
    }
    
    static func imageWithPath(_ path:String) -> TmdbImage? {
        guard links[path] != nil else {
            return nil
        }
        
        let image = MoobeezManager.shared.tmdbDatabase.context.object(with: (MoobeezManager.shared.tmdbDatabase.context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: links[path]!))!) as! TmdbImage
        
        return image
    }
    
    static func fetchImageWithPath(_ path:String) -> TmdbImage? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TmdbImage")
        fetchRequest.predicate = NSPredicate(format: "path == %@", path)
        
        do {
            let fetchedItems:[TmdbImage] = try MoobeezManager.shared.tmdbDatabase.context.fetch(fetchRequest) as! [TmdbImage]
            
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
