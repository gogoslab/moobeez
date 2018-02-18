//
//  TeebeeEpisode.swift
//  Moobeez
//
//  Created by Radu Banea on 02/11/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import CoreData

extension TeebeeEpisode {
    
    @objc var formattedDate:String {
        get {            
            let today = Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: (SettingsManager.shared.addExtraDay ? -24 * 3600 : 0)))
            let tommorow = today.addingTimeInterval(24 * 3600)
            let nextWeek = today.addingTimeInterval(7 * 24 * 3600)

            if releaseDate?.compare(today) == ComparisonResult.orderedAscending {
                return ""
            }
            else if releaseDate?.compare(tommorow) == ComparisonResult.orderedAscending {
                return "Today"
            }
            else if releaseDate?.compare(tommorow.addingTimeInterval(24 * 3600)) == ComparisonResult.orderedAscending {
                return "Tommorow"
            }
            else if releaseDate?.compare(today.endOfWeek!) == ComparisonResult.orderedAscending  || releaseDate?.compare(today.endOfWeek!) == ComparisonResult.orderedSame {
                return "This week"
            }
            else if releaseDate?.compare(nextWeek.endOfWeek!) == ComparisonResult.orderedAscending  || releaseDate?.compare(nextWeek.endOfWeek!) == ComparisonResult.orderedSame {
                return "Next week"
            }

            return "Soon"
        }
    }
}
