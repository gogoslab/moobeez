//
//  WidgetManager.swift
//  Today
//
//  Created by Radu Banea on 25/11/2018.
//  Copyright © 2018 Gogo's Lab. All rights reserved.
//

import UIKit

class WidgetManager: NSObject {

    static var episodes:[Teebee.Episode] {
        get {
            let today = Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: (SettingsManager.shared.addExtraDay ? -24 * 3600 : 0)))

            return MoobeezManager.shared.moobeezDatabase.fetch(predicate: NSPredicate(format: "watched == 0 AND releaseDate < %@ AND releaseDate.timeIntervalSince(.distantPast) > 100 AND season.teebee.isFavorite == true", today as CVarArg), sort: [NSSortDescriptor(key: "releaseDate", ascending: true), NSSortDescriptor(key: "number", ascending: true)])
        }
    }
    
}
