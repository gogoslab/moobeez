//
//  MoobeeViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 20/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class MoobeeToolboxView : UIVisualEffectView {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var starsView: StarsView!
    @IBOutlet var seenDateLabel: UILabel!

    
}

class MoobeeDetailsViewController: MBViewController {

    var bee:Bee?
    
    @IBOutlet var posterImageView:UIImageView!
    @IBOutlet var contentView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        contentView.isHidden = true
        
        loadPoster()
    }

    func loadPoster() {
        
        var tmdbItem:TmdbItem? = nil
        
        if bee is Moobee {
            tmdbItem = (bee as! Moobee).movie!
        } else if bee is Teebee {
            tmdbItem = (bee as! Teebee).tvShow!
        }
        
        guard tmdbItem != nil else {
            return
        }
        
        posterImageView.loadTmdbPosterWithPath(path: tmdbItem!.posterPath!) { (didLoadImage) in
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        contentView.isHidden = false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backButtonPressed(_ sender: UIButton) {
        contentView.isHidden = true
        hideDetailsViewController()
    }
    
}

extension MoobeeDetailsViewController {
    
    
    
}
