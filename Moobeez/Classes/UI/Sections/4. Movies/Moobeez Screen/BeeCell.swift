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
        willSet {
            NotificationCenter.default.removeObserver(self, name: .BeeDidChangeNotification, object: bee?.tmdbId)
        }
        didSet {
            
            if bee is Moobee {
                headerView.isHidden = (bee as! Moobee).moobeeType != MoobeeType.seen
            }
            
            starsView.rating = CGFloat(bee?.rating ?? 0.0)
            
            nameLabel.text = bee?.name
            nameLabel.isHidden = false
            
            posterImageView.loadTmdbPosterWithPath(path: (bee?.posterPath)!, placeholder:nil) { (didLoadImage) in
                self.nameLabel.isHidden = didLoadImage
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.beeChanged), name: .BeeDidChangeNotification, object: bee?.tmdbId)
            
        }
    }
    
    @objc func beeChanged(notification: NSNotification){
        posterImageView.loadTmdbPosterWithPath(path: (bee?.posterPath)!, placeholder:nil) { (didLoadImage) in
            self.nameLabel.isHidden = didLoadImage
        }
        starsView.rating = CGFloat(bee?.rating ?? 0.0)
        nameLabel.text = bee?.name
        
        if bee is Moobee {
            headerView.isHidden = (bee as! Moobee).moobeeType != MoobeeType.seen
        }
    }
}
