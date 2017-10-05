//
//  CastThumbnailCell.swift
//  Moobeez
//
//  Created by Radu Banea on 04/10/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class CastThumbnailCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    var person:TmdbPerson? {
        didSet {
            guard person != nil else {
                return
            }
            
            if person!.profilePath != nil {
                imageView.loadTmdbProfileWithPath(path: (person!.profilePath)!)
            }
            else
            {
                imageView.image = #imageLiteral(resourceName: "default_image")
            }
            imageView.layer.cornerRadius = imageView.width / 2
        }
    }
    
    var movie:TmdbItem? {
        didSet {
            guard movie != nil else {
                return
            }
            
            if movie!.posterPath != nil {
                imageView.loadTmdbPosterWithPath(path: (movie!.posterPath)!)
            }
            else
            {
                imageView.image = #imageLiteral(resourceName: "default_image")
            }
            imageView.layer.cornerRadius = 0
        }
    }
    
}
