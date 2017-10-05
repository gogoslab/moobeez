//
//  BeeCell.swift
//  Moobeez
//
//  Created by Radu Banea on 11/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit
import SDWebImage

class BeeCell: UICollectionViewCell {

    @IBOutlet var headerView:UIView!
    @IBOutlet var starsView:StarsView!
    @IBOutlet var posterImageView:UIImageView!
    @IBOutlet var nameLabel:UILabel!
    
    
    var bee:Bee? {
        didSet {
            
            var tmdbItem:TmdbItem? = nil
                
            if bee is Moobee {
                tmdbItem = (bee as! Moobee).movie!
            } else if bee is Teebee {
                tmdbItem = (bee as! Teebee).tvShow!
            }
            
            guard tmdbItem != nil else {
                return
            }
            
            if bee is Moobee {
                headerView.isHidden = (bee as! Moobee).moobeeType != MoobeeType.seen
            }
            
            starsView.rating = CGFloat(bee?.rating ?? 0.0)
            
            nameLabel.text = bee?.name
            
            posterImageView.loadTmdbPosterWithPath(path: tmdbItem!.posterPath!) { (didLoadImage) in
                self.nameLabel.isHidden = didLoadImage
            }
        }
    }
}