//
//  TeebeeSeason.swift
//  Moobeez
//
//  Created by Radu Banea on 09/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import CoreData

extension TeebeeSeason {
    
    func episodeWithNumber(number:Int16) -> TeebeeEpisode
    {
        if episodes != nil {
            for episode:TeebeeEpisode in Array(episodes!) as! [TeebeeEpisode]
            {
                if (episode.number == number)
                {
                    return episode
                }
            }
        }
        
        let episode:TeebeeEpisode = NSEntityDescription.insertNewObject(forEntityName: "TeebeeEpisode", into: MoobeezManager.coreDataContex!) as! TeebeeEpisode
        
        episode.number = number
        episode.season = self
        
        addToEpisodes(episode)
        
        return episode
    }
    
}
