//
//  MBSideMenuController.swift
//  Moobeez
//
//  Created by Radu Banea on 02/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class MBSideMenuController: UIViewController {

    static var instance:MBSideMenuController? = nil
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var backgroundBluredImageView: UIImageView!
    
    @IBOutlet var menuView: UIView!

    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var checkInMovieButton: UIButton!
    @IBOutlet var checkInTvShowButton: UIButton!
    
    @IBOutlet var notWatchedTvShowsLabel: UILabel!
    
    @IBOutlet var containerView: UIView!
    
    var childNavigationController: MBNavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        MBSideMenuController.instance = self
        
        // Do any additional setup after loading the view.
        for vc in self.children {
            if vc is MBNavigationController {
                childNavigationController = vc as? MBNavigationController
                break;
            }
        }
        
        performSegue(withIdentifier: "ShowTimelineSegue", sender: nil)
    }

    public func showMenu(_ animated:Bool = true)
    {
        NotificationCenter.default.post(name: .SideMenuWillAppearNotification, object: nil)
        
        backgroundBluredImageView.alpha = 0.0
        menuView.alpha = 0.0

        UIView.animate(withDuration: (animated ? 0.4 : 0.0)) {
            self.containerView.transform = __CGAffineTransformMake(0.5, 0.0, 0.0, 0.5, self.view.frame.size.width * 1 / 5, 0.0)
            self.backgroundBluredImageView.alpha = 1.0
        }
        
        UIView.animate(withDuration: (animated ? 0.2 : 0.0), delay: (animated ? 0.2 : 0.0), options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            self.menuView.alpha = 1.0
        }, completion: { (_) in
            
        })
        
        containerView.isUserInteractionEnabled = false
        
    }
    
    public func hideMenu() {

        view.bringSubviewToFront(containerView)
        containerView.isHidden = false

        hideMenu(true)

    }
    
    public func hideMenu(_ animated:Bool)
    {
        NotificationCenter.default.post(name: .SideMenuWillDissappearNotification, object: nil)
        
        UIView.animate(withDuration: (animated ? 0.4 : 0.0)) {
            self.containerView.transform = CGAffineTransform.identity
            self.backgroundBluredImageView.alpha = 0.0;
        }
        
        UIView.animate(withDuration: (animated ? 0.2 : 0.0), animations: {
            self.menuView.alpha = 0.0
        }, completion: { (_) in
            
        })
        
        containerView.isUserInteractionEnabled = true
        
    }

    @IBAction func backgroundTapped(_ sender: Any) {
        hideMenu()
    }

    public func showViewController(_ vc: UIViewController) {
        
        self.childNavigationController.showViewController(vc as! MBViewController)
        
        hideMenu()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowDashboardSegue" {
            (segue.destination as! TimelineViewController).future = false
        }
    }
}
