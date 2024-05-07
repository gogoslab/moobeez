//
//  Tmdb.Image.swift
//  Moobeez
//
//  Created by Radu Banea on 04/10/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import Foundation
import CoreData

extension Tmdb {
    
    class Image: Codable {
        
        var path: String?
        var aspectRatio: Float = 1
        var isPoster: Bool = true
        
        
        enum CodingKeys: String, CodingKey {
            case path
            case aspectRatio
            case isPoster
        }
        
        init (tmdbDictionary: [String : Any]) {
            addEntriesFrom(tmdbDictionary: tmdbDictionary)
        }
        
        func addEntriesFrom(tmdbDictionary: [String : Any]) {
            
            path = tmdbDictionary["file_path"] as? String
            
            aspectRatio = (tmdbDictionary["aspect_ratio"] as? NSNumber)?.floatValue ?? 1
        }
    }
}
