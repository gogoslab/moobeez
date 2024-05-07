//
//  EpisodeCell.swift
//  Moobeez
//
//  Created by Radu Banea on 07/11/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {
    
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
    
    var episode:Teebee.Episode? {
        didSet
        {
            NotificationCenter.default.removeObserver(self, name: Notification.Name.TeebeeEpisodeDidChangeNotification, object: oldValue?.tmdbId)

            nameLabel.text = episode?.name
            episodeNumberLabel.text = "\(episode?.number ?? 0)"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            detailsLabel.text = dateFormatter.string(from: (episode?.releaseDate)!)
            
            reloadData()
            
            NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name.TeebeeEpisodeDidChangeNotification, object: episode?.tmdbId)
        }
    }
    
    @objc func reloadData() {
        watchButton.isSelected = episode?.watched ?? false
    }
    
    @IBAction func watchButtonPressed(_ sender: Any) {
        episode?.watched = !(episode?.watched ?? false)
        reloadData()
        MoobeezManager.shared.save()
        
        NotificationCenter.default.post(name: .TeebeeSeasonDidChangeNotification , object: episode?.season)
        NotificationCenter.default.post(name: .TeebeezDidChangeNotification , object: nil)
    }
}
