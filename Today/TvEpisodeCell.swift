//
//  TvEpisodeCell.swift
//  Today
//
//  Created by Radu Banea on 01/11/2018.
//  Copyright © 2018 Gogolabs. All rights reserved.
//

import UIKit

class TvEpisodeCell: UICollectionViewCell {
    
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    
    var episode:TeebeeEpisode? {
        didSet
        {
            if let episode = episode {
                titleLabel.text = "S\(episode.season?.number ?? 0)E\(episode.number)"
                posterImageView.loadTmdbPosterWithPath(path: episode.season?.teebee?.posterPath, placeholder:#imageLiteral(resourceName: "default_image"))
            }
        }
    }
    
    @IBAction func watchButtonPressed(_ sender: Any) {
        episode?.watched = !(episode?.watched ?? false)
        MoobeezManager.shared.save()
    }
}
