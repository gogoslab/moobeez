//
//  BoardingViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 08.01.2024.
//  Copyright © 2024 Gogo's Lab. All rights reserved.
//

import UIKit
import Firebase

class BoardingViewController: ConnectViewController {
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var buttonsStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FirebaseApp.allApps?.isEmpty ?? true {            
            FirebaseApp.configure()
        }
        
        self.buttonsStackView.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            if Auth.auth().currentUser == nil {
                UIView.animate(withDuration: 0.3) {
                    self.buttonsStackView.isHidden = false
                    self.stackView.layoutIfNeeded()
                }
            }
            else {
                self.goToMain()
            }
        })
        
    }
    
    override func signUpComplete() {
        goToMain()
    }
    
    func goToMain() {
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "Main")
    }
    
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        goToMain()
    }
}
