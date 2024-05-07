//
//  Bee.swift
//  Moobeez
//
//  Created by Mobilauch Labs on 26.03.2024.
//  Copyright © 2024 Gogo's Lab. All rights reserved.
//

import Foundation

protocol Bee {
    
    var id: UUID { get set }
    
    var name: String { get set }
    
    var date: Date? { get set }
    
    var posterPath: String? { get set }
    var backdropPath: String? { get set }
    var releaseDate: Date? { get set }
    var rating: Float { get set }
    var tmdbId: String? { get set }

}
