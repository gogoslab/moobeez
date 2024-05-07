//
//  TimelineItem.swift
//  Moobeez
//
//  Created by Radu Banea on 24/02/2018.
//  Copyright © 2018 Gogo's Lab. All rights reserved.
//

import UIKit

class TimelineItem: NSObject {

    convenience init(moobee:Moobee) {
        self.init()
        self.moobee = moobee
        
        if moobee.type == .seen {
            date = moobee.date
        }
        else {
            date = moobee.releaseDate
        }
        
        date = Calendar.current.startOfDay(for: date!)
        
        dateString = date?.string(withFormat: "YYYY-MM-DD")
    }
    
    convenience init(episode:Teebee.Episode) {
        self.init()
        self.teebeeEpisode = episode
        
        date = teebeeEpisode?.releaseDate
        
        date = Calendar.current.startOfDay(for: date!)
        
        dateString = date?.string(withFormat: "YYYY-MM-DD")
    }
    
    var moobee:Moobee?
    
    var teebeeEpisode:Teebee.Episode?
    
    var name:String? {
        get {
            if moobee != nil {
                return moobee!.name
            }
            
            if teebeeEpisode != nil {
                return teebeeEpisode!.season!.teebee!.name
            }
            
            return nil
        }
    }
    
    var subtitle:String? {
        get {
            if teebeeEpisode != nil {
                return "Season \(teebeeEpisode!.season!.number) Episode \(teebeeEpisode!.number)"
            }
            
            return nil
        }
    }

    var date:Date?
    var dateString:String?
    
    var backdropPath:String? {
        get {
            if moobee != nil {
                return moobee!.backdropPath
            }
            
            if teebeeEpisode != nil {
                return teebeeEpisode!.season!.teebee!.backdropPath
            }
            
            return nil
        }
    }
    
    var watched:Bool? {
        get {
            if moobee != nil {
                return moobee!.type == .seen
            }
            
            if teebeeEpisode != nil {
                return teebeeEpisode!.watched
            }
            
            return nil
        }
    }
    
    var rating:Float {
        if moobee != nil {
            if moobee!.type == .seen {
                return moobee!.rating
            }
        }
        
        return -1
    }
    
}
