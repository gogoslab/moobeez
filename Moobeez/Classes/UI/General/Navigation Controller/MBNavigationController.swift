//
//  MBNavigationController.swift
//  Moobeez
//
//  Created by Radu Banea on 02/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class MBNavigationController: UINavigationController {

    var swipeGesture: UISwipeGestureRecognizer?
    var rootViewController: MBViewController?
    
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
    
    public func removeSideAction() {
        topViewController?.navigationItem.leftBarButtonItem = nil;
        topViewController?.view.removeGestureRecognizer(swipeGesture!)
    }
    
    public func showViewController(_ vc: MBViewController) {
        
        guard rootViewController == nil ||  rootViewController!.isSame(with: vc) == false else {
            return
        }
        
        if rootViewController != nil {
            rootViewController?.view.removeGestureRecognizer(swipeGesture!)
        }
        
        viewControllers = [vc]
        
        rootViewController = vc
        
        rootViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu_button"), style: .plain, target: self, action:#selector(showMenu))
        
        swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(showMenu))
        swipeGesture?.direction = .right
        rootViewController?.view.addGestureRecognizer(swipeGesture!)
    }

    @objc func showMenu() {
        MBSideMenuController.instance?.showMenu()
    }
}
