//
//  SeasonCell.swift
//  Moobeez
//
//  Created by Radu Banea on 07/11/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class SeasonCell: UICollectionViewCell {
    
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var watchButton: ThemedButton!
    
    @IBAction func watchButtonPressed(_ sender: Any) {
    }
    
    func applyTheme(lightTheme: Bool) {
        if detailsLabel != nil {
            detailsLabel.textColor = lightTheme ? UIColor.white : UIColor.black
        }
    }
    
    var season:TeebeeSeason? {
        didSet
        {
            nameLabel.text = "Season \(season?.number ?? 0)"
            if season?.posterPath != nil
            {
                posterImageView.loadTmdbPosterWithPath(path: (season?.posterPath)!)
            }
            else
            {
                posterImageView.image = #imageLiteral(resourceName: "default_image")
            }
            
            let details:NSMutableAttributedString = NSMutableAttributedString()
            details.append(NSAttributedString(string: "\(season?.notWatchedEpisodesCount ?? 0)", attributes: [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.2039215714, green: 0.6666666865, blue: 0.8627451062, alpha: 1)]))
            details.append(NSAttributedString(string: " / "))
            details.append(NSAttributedString(string: "\(season?.episodes?.count ?? 0)", attributes: [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.2039215714, green: 0.6666666865, blue: 0.8627451062, alpha: 1)]))
            details.append(NSAttributedString(string: " episodes watched"))

            detailsLabel.attributedText = details
        }
    }
}
