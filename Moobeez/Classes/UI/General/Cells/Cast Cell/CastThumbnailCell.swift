//
//  CastThumbnailCell.swift
//  Moobeez
//
//  Created by Radu Banea on 04/10/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import UIKit

class CastThumbnailCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    
    func applyTheme(lightTheme: Bool) {
        if detailsLabel != nil {
            detailsLabel.textColor = lightTheme ? UIColor.white : UIColor.black
        }
    }
    
    var person:Tmdb.Person? {
        didSet {
            guard person != nil else {
                return
            }
            
            if person!.profilePath != nil {
                imageView.loadTmdbProfileWithPath(path: person!.profilePath)
            }
            else
            {
                imageView.image = #imageLiteral(resourceName: "default_image")
            }
            imageView.layer.cornerRadius = imageView.width / 2
            
            if nameLabel != nil {
                nameLabel.text = person?.name
            }
            
        }
    }
    
    var character:Tmdb.Character? {
        didSet {
            guard character != nil else {
                return
            }
            
            if detailsLabel != nil && character?.name != nil {
                detailsLabel.text = "as " + (character?.name)!
            }
        }
    }
    
    var movie:Tmdb.Item? {
        didSet {
            guard movie != nil else {
                return
            }
            
            imageView.loadTmdbPosterWithPath(path: movie!.posterPath, placeholder:#imageLiteral(resourceName: "default_image"))
            imageView.layer.cornerRadius = 0
            
            if nameLabel != nil {
                nameLabel.text = movie?.name
            }
        }
    }
    
}
