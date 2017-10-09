//
//  TmdbTvSeason.swift
//  Moobeez
//
//  Created by Radu Banea on 09/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import CoreData

extension TmdbTvSeason {
    
    func episodeWithNumber(number:Int16) -> TmdbTvEpisode
    {
        if episodes != nil {
            for episode:TmdbTvEpisode in episodes?.array as! [TmdbTvEpisode]
            {
                if (episode.episodeNumber == number)
                {
                    return episode
                }
            }
        }
        
        let episode:TmdbTvEpisode = NSEntityDescription.insertNewObject(forEntityName: "TmdbTvEpisode", into: MoobeezManager.shared.tempContainer.viewContext) as! TmdbTvEpisode
        
        episode.episodeNumber = number
        episode.season = self
        
        addToEpisodes(episode)
        
        return episode
    }
    
}
