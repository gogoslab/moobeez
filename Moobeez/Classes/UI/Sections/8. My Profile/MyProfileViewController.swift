//
//  MyProfileViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 08.01.2024.
//  Copyright © 2024 Gogo's Lab. All rights reserved.
//

import UIKit
import FirebaseAuth

class MyProfileViewController: MBViewController {

    
    @IBOutlet var completeProfileView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Auth.auth().currentUser == nil {
            completeProfileView.superview?.bringSubviewToFront(completeProfileView)
            completeProfileView.isHidden = false
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
