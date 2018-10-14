//
//  MBViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 02/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class MBViewController: UIViewController {

    var presenting:MBViewController?

    var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return statusBarStyle
        }
    }
    
    func addTitleLogo() {
        self.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "header_logo.png"))
    }
    
    func showDetailsViewController(_ viewController: MBViewController)
    {
        let parentView = (MBSideMenuController.instance?.view)!
        
        parentView.addSubview(viewController.view)
        
        let windowBounds:CGRect = parentView.bounds
        
        viewController.view.frame = windowBounds
        
        MBSideMenuController.instance?.addChild(viewController)
        
        viewController.presenting = self
        
        let summaryView:UIView? = summaryViewForViewController(viewController)
        
        guard summaryView != nil else {
            viewController.didMove(toParent: self)
            return;
        }
        
        viewController.view.center = (self.view.window?.convert((summaryView?.center)!, from: summaryView?.superview))!
        
        viewController.view.transform = CGAffineTransform.init(scaleX: (summaryView?.frame.size.width)! / windowBounds.size.width,
                                                               y: (summaryView?.frame.size.height)! / windowBounds.size.height)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            viewController.view.center = CGPoint.init(x: windowBounds.size.width / 2, y: windowBounds.size.height / 2)
            viewController.view.transform = CGAffineTransform.identity
            
        }, completion: { (_) in
            viewController.didMove(toParent: self)
        })
    }
    
    func summaryViewForViewController(_ viewController: UIViewController) -> UIView? {
        return nil
    }
    
    func hideDetailsViewController()
    {
        guard presenting != nil else {
            return
        }
        
        let summaryView:UIView? = presenting!.summaryViewForViewController(self)
        
        guard summaryView != nil else {
            presenting!.viewWillAppear(false)
            didMove(toParent: nil)
            removeFromParent()
            view.removeFromSuperview()
            presenting!.viewDidAppear(false)
            return;
        }
        
        presenting!.viewWillAppear(true)
        
        let windowBounds:CGRect = ((MBSideMenuController.instance?.view)!.bounds)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.view.center = (self.view.window?.convert((summaryView?.center)!, from: summaryView?.superview))!
            
            self.view.transform = CGAffineTransform.init(scaleX: (summaryView?.frame.size.width)! / windowBounds.size.width,
                                                                   y: (summaryView?.frame.size.height)! / windowBounds.size.height)
            
            
        }, completion: { (_) in
            self.didMove(toParent: nil)
            self.removeFromParent()
            self.view.removeFromSuperview()
            self.presenting!.viewDidAppear(true)
        })
    }
    
    func isSame(with viewController:MBViewController) -> Bool {
        return object_getClassName(self) == object_getClassName(viewController)
    }

}
