//
//  TmdbItem.swift
//  Moobeez
//
//  Created by Mobilauch Labs on 27.03.2024.
//  Copyright © 2024 Gogo's Lab. All rights reserved.
//

import Foundation

extension Tmdb {
    
    protocol Item {
        
        var id: String { get set }
        
        var name: String { get set }
        var overview: String { get set }
        
        var imdbId: String? { get set }
        
        var backdropPath: String? { get set }
        var posterPath: String? { get set }
        
        var comments: String? { get set }
        
        var popularity: Float { get set }
        
        var releaseDate: Date? { get set }
        
    }
}
