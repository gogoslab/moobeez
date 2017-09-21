//
//  MBViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 02/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class MBViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    func showDetailsViewController(_ viewController: UIViewController)
    {
        self.view.window?.addSubview(viewController.view)
        
        let windowBounds:CGRect = (self.view.window?.bounds)!
        
        viewController.view.frame = windowBounds
        
        self.addChildViewController(viewController)
        
        let summaryView:UIView? = summaryViewForViewController(viewController)
        
        guard summaryView != nil else {
            viewController.didMove(toParentViewController: self)
            return;
        }
        
        viewController.view.center = (self.view.window?.convert((summaryView?.center)!, from: summaryView?.superview))!
        
        viewController.view.transform = CGAffineTransform.init(scaleX: (summaryView?.frame.size.width)! / windowBounds.size.width,
                                                               y: (summaryView?.frame.size.height)! / windowBounds.size.height)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            viewController.view.center = CGPoint.init(x: windowBounds.size.width / 2, y: windowBounds.size.height / 2)
            viewController.view.transform = CGAffineTransform.identity
            
        }, completion: { (_) in
            viewController.didMove(toParentViewController: self)
        })
    }
    
    func summaryViewForViewController(_ viewController: UIViewController) -> UIView? {
        return nil
    }
    
    func hideDetailsViewController()
    {
        guard parent != nil else {
            return
        }
        
        guard parent is MBViewController else {
            return
        }
        
        let parentViewController:MBViewController = parent as! MBViewController
        
        let summaryView:UIView? =  parentViewController.summaryViewForViewController(self)
        
        guard summaryView != nil else {
            didMove(toParentViewController: nil)
            removeFromParentViewController()
            view.removeFromSuperview()
            return;
        }
        
        let windowBounds:CGRect = (self.view.window?.bounds)!
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.view.center = (self.view.window?.convert((summaryView?.center)!, from: summaryView?.superview))!
            
            self.view.transform = CGAffineTransform.init(scaleX: (summaryView?.frame.size.width)! / windowBounds.size.width,
                                                                   y: (summaryView?.frame.size.height)! / windowBounds.size.height)
            
            
        }, completion: { (_) in
            
            self.didMove(toParentViewController: nil)
            self.removeFromParentViewController()
            self.view.removeFromSuperview()
        })
    }

}
