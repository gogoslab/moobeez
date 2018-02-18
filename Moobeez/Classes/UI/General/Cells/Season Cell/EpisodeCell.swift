//
//  EpisodeCell.swift
//  Moobeez
//
//  Created by Radu Banea on 07/11/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class EpisodeCell: UICollectionViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var episodeNumberLabel: UILabel!
    @IBOutlet var watchButton: ThemedButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        episodeNumberLabel.borderWidth = 1.0
        episodeNumberLabel.borderColor = #colorLiteral(red: 0.2039215714, green: 0.6666666865, blue: 0.8627451062, alpha: 1)
        episodeNumberLabel.cornerRadius = episodeNumberLabel.width / 2
    }
    
    func applyTheme(lightTheme: Bool) {
        if detailsLabel != nil {
            detailsLabel.textColor = lightTheme ? UIColor.white : UIColor.black
        }
    }
    
    var episode:TeebeeEpisode? {
        didSet
        {
            nameLabel.text = episode?.name
            episodeNumberLabel.text = "\(episode?.number ?? 0)"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            detailsLabel.text = dateFormatter.string(from: (episode?.releaseDate)!)
        }
    }
}
