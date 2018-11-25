//
//  SeasonCell.swift
//  Moobeez
//
//  Created by Radu Banea on 07/11/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import UIKit

class SeasonCell: UITableViewCell {
    
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var watchButton: ThemedButton!
    
    var tapGesture:UITapGestureRecognizer?
    
    @IBAction func watchButtonPressed(_ sender: Any) {
        season?.episodes?.enumerateObjects({ (episode, _, _) in
            (episode as! TeebeeEpisode).watched = !watchButton.isSelected
            NotificationCenter.default.post(name: .TeebeeEpisodeDidChangeNotification , object: (episode as! TeebeeEpisode).tmdbId)
        })
        watchButton.isSelected = !watchButton.isSelected
        MoobeezManager.shared.save()
        reloadData()
        NotificationCenter.default.post(name: .TeebeezDidChangeNotification , object: nil)
    }
    
    func applyTheme(lightTheme: Bool) {
        if detailsLabel != nil {
            detailsLabel.textColor = lightTheme ? UIColor.white : UIColor.black
        }
    }
    
    var season:TeebeeSeason? {
        didSet
        {
            NotificationCenter.default.removeObserver(self, name: Notification.Name.TeebeeSeasonDidChangeNotification, object: oldValue)
            
            guard season != nil else {
                return
            }
            
            nameLabel.text = "Season \(season!.number)"
            posterImageView.loadTmdbPosterWithPath(path: season!.posterPath)
            
            reloadData()
            
            NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name.TeebeeSeasonDidChangeNotification, object: season)
        }
    }
    
    @objc func reloadData() {
        guard season != nil else {
            return
        }
        
        watchButton.isSelected = season!.watched
        
        let details:NSMutableAttributedString = NSMutableAttributedString()
        details.append(NSAttributedString(string: "\(season!.watchedEpisodesCount)", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.2039215714, green: 0.6666666865, blue: 0.8627451062, alpha: 1)]))
        details.append(NSAttributedString(string: " / "))
        details.append(NSAttributedString(string: "\(season!.episodes!.count)", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.2039215714, green: 0.6666666865, blue: 0.8627451062, alpha: 1)]))
        details.append(NSAttributedString(string: " episodes watched"))
        
        detailsLabel.attributedText = details
        

    }
}
