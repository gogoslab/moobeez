//
//  VideoViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 26/10/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit
import AVKit

class VideoViewController: AVPlayerViewController {

    var trailerPath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if trailerPath != nil {
            player = AVPlayer(url: URL(string: trailerPath!)!)
            player?.play()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
