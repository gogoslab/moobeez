//
//  Moobee.swift
//  Moobeez
//
//  Created by Radu Banea on 21/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import CoreData

enum MoobeeType: Int16 {
    case none = 0;
    case watchlist = 1;
    case seen = 2;
    
    case all = 3;
    
    case new = 4;
    case discarded = 5;
}

extension Moobee {
    
    var moobeeType:MoobeeType {
        get {
            return MoobeeType(rawValue: type)!
        }
        set (moobeeType) {
            type = moobeeType.rawValue
        }
    }
    
    convenience init(tmdbMovie movie:TmdbMovie) {
        
        self.init(entity: NSEntityDescription.entity(forEntityName: "Moobee", in: MoobeezManager.coreDataContex!)!, insertInto: nil)
        
        self.tmdbId = movie.tmdbId
        self.name = movie.name
        self.moobeeType = .new
        self.rating = 2.5
        self.date = Date()
    }
}
