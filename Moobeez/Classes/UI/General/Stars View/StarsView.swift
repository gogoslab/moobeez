//
//  StarsView.swift
//  Moobeez
//
//  Created by Radu Banea on 11/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import UIKit

class StarsView: UIView {

    @IBOutlet var emptyStarsImageView: UIImageView!
    @IBOutlet var fullStarsImageView: UIImageView!
    
    @IBOutlet var widthConstraint: NSLayoutConstraint!

    private static var maxRating: CGFloat = 5
    
    private var panGesture:UIPanGestureRecognizer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(recognizer:)))
        addGestureRecognizer(panGesture!)
        
    }
    var rating: CGFloat = maxRating {
        willSet(newRating) {
            percent = newRating / StarsView.maxRating
        }
    }
    var ratingInPixels: CGFloat = 0 {
        
        didSet {
            percent = ratingInPixels / width
        }
        
    }
    
    var percent: CGFloat = 0 {
        didSet {
            removeConstraint(widthConstraint)
            widthConstraint = NSLayoutConstraint(item: fullStarsImageView, attribute: NSLayoutConstraint.Attribute.width,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self, attribute: NSLayoutConstraint.Attribute.width,
                                                 multiplier: percent, constant: 0)
            addConstraint(widthConstraint)
        }
    }

    var updateHandler: EmptyHandler?

    @objc @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        
        if recognizer.state == .began {
            
        }
        else if recognizer.state == .changed {
            
            var point:CGFloat = recognizer.location(in: self).x
            
            point = max(min(point, width), 0)
            
            point = round(point / (width / 10)) * (width / 10)
            
            ratingInPixels = point;
            
        }
        else if recognizer.state == .ended || recognizer.state == .cancelled {
            rating = ratingInPixels / width * StarsView.maxRating
            
            if updateHandler != nil {
                updateHandler!()
            }
            
        }
    }
}
