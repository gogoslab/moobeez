//
//  VideoViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 25/10/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class YoutubeVideoViewController: MBViewController {

    @IBOutlet var youtubePlayerView: YTPlayerView!
    var trailerPath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if trailerPath != nil {
            youtubePlayerView.load(withVideoId: trailerPath!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        (UIApplication.shared.delegate as! AppDelegate).isPortrait = true
        dismiss(animated: true, completion: nil)
    }
}
