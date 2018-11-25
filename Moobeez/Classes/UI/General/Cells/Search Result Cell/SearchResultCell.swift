//
//  SearchResultCell.swift
//  Moobeez
//
//  Created by Radu Banea on 09/10/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet var posterImageView:UIImageView!
    
    @IBOutlet var titleLabel:UILabel!
    
    @IBOutlet var detailsLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var movie:TmdbMovie?
    {
        didSet {
            posterImageView.loadTmdbPosterWithPath(path: movie?.posterPath, placeholder:#imageLiteral(resourceName: "default_image"))
            titleLabel.text = movie?.name
            
            if movie?.releaseDate != nil {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM yyyy"
                detailsLabel.text = dateFormatter.string(from: (movie?.releaseDate)!)
            }
            else {
                detailsLabel.text = ""
            }
            
            detailsLabel.isHidden = (detailsLabel.text?.count == 0)
        }
    }
    
    var person:TmdbPerson?
    {
        didSet {
            posterImageView.loadTmdbProfileWithPath(path: person?.profilePath)
            titleLabel.text = person?.name
            
            detailsLabel.text = person?.overview ?? ""
            
            detailsLabel.isHidden = (detailsLabel.text?.count == 0)
        }
    }
    
    var tvShow:TmdbTvShow?
    {
        didSet {
            posterImageView.loadTmdbPosterWithPath(path: tvShow?.posterPath, placeholder:#imageLiteral(resourceName: "default_image"))
            titleLabel.text = tvShow?.name
            
            if tvShow?.releaseDate != nil {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM yyyy"
                detailsLabel.text = dateFormatter.string(from: (tvShow?.releaseDate)!)
            }
            else {
                detailsLabel.text = ""
            }
        }
    }

}
