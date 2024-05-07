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
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "Boarding")
        }
        catch let error {
            debugPrint(error.localizedDescription)
        }
        
        
    }
    

}
