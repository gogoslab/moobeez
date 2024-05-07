//
//  Moobee.swift
//  Moobeez
//
//  Created by Radu Banea on 21/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import Foundation
import CoreData

enum MoobeeType: Int, Codable {
    case none = 0;
    case watchlist = 1;
    case seen = 2;
    
    case all = 3;
    
    case new = 4;
    case discarded = 5;
}

class Moobee: Bee, Identifiable, Equatable, Codable {
    
    static func == (lhs: Moobee, rhs: Moobee) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id = UUID()
    
    var name: String
    
    var date: Date?
    
    var posterPath: String?
    var backdropPath: String?
    var releaseDate: Date?
    var rating: Float = 5
    var tmdbId: String?

    var isFavorite: Bool = false
    var type: MoobeeType = .none
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case date
        case posterPath
        case backdropPath
        case releaseDate
        case rating
        case tmdbId

        case isFavorite
        case type
    }
    
    init(tmdbMovie movie:Tmdb.Movie) {
        
        self.name = movie.name
        self.type = .new
        self.rating = 2.5
        self.date = Date()
        
        self.movie = movie
    }
    
    
}

extension Moobee {
    
    static func fetchMoobeeWithTmdbId(_ tmdbId: String) -> Moobee? {
        
        return MoobeezManager.shared.moobeez.first { moobee in
            moobee.tmdbId == tmdbId
        }
    }
    

    var movie:Tmdb.Movie? {
        get {
            return tmdbId == nil ? nil : Tmdb.Movies[tmdbId!]
        }
        set (movie) {
            
            guard movie != nil else {
                tmdbId = nil
                return
            }
            
            tmdbId = movie!.id
            posterPath = movie!.posterPath
            backdropPath = movie!.backdropPath
            releaseDate = movie!.releaseDate
            
            MoobeezManager.shared.save()
            
            NotificationCenter.default.post(name: .BeeDidChangeNotification, object: tmdbId)
        }
    }
    
    public var description: String {
        get {
            return "\(self.name))"
        }
    }
}

extension Moobee {
    
    var file: URL {
        get {
            return URL.moobeezDirectory.appendingPathComponent(id.uuidString)
        }
    }
    
    func save() {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            print("Writing...  📖: \(file.description)")
            try encoder.encode(self).write(to: file)
        } catch {
            print("Couldn’t save new entry to \(file), \(error.localizedDescription)")
        }
    }
    
    func delete() {
        
        do {
            try FileManager.default.removeItem(at: file)
        } catch {
            
        }
        
    }
    
}
