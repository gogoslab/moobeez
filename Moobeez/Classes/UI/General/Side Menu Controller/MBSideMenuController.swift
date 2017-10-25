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
        for vc in self.childViewControllers {
            if vc is MBNavigationController {
                childNavigationController = vc as! MBNavigationController
                break;
            }
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
    
    public func showMenu() {
        
        showMenu(true);
    }
    
    public func showMenu(_ animated:Bool)
    {
        NotificationCenter.default.post(name: .SideMenuWillAppearNotification, object: nil)
        
        backgroundBluredImageView.alpha = 0.0;
        menuView.alpha = 0.0;

        UIView.animate(withDuration: (animated ? 0.4 : 0.0)) {
            self.containerView.transform = __CGAffineTransformMake(0.5, 0.0, 0.0, 0.5, self.view.frame.size.width * 1 / 5, 0.0)
            self.backgroundBluredImageView.alpha = 1.0;
        }
        
        UIView.animate(withDuration: (animated ? 0.2 : 0.0), delay: (animated ? 0.2 : 0.0), options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
            self.menuView.alpha = 1.0
        }, completion: { (_) in
            
        })
        
        containerView.isUserInteractionEnabled = false;
        
    }
    
    public func hideMenu() {

        view.bringSubview(toFront: containerView)
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
        
        containerView.isUserInteractionEnabled = true;
        
    }


    public func showViewController(_ vc: UIViewController) {
        
        self.childNavigationController.showViewController(vc)
        
        hideMenu()
    }
    
}
