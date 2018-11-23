//
//  DeepLinking.swift
//  Moobeez
//
//  Created by Radu Banea on 23/11/2018.
//  Copyright © 2018 Gogolabs. All rights reserved.
//

import UIKit

class DeepLinking: NSObject {
    
    private static var cachedUrl:URL?
    
    static func parse(_ url:URL) {
        
        let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false)
        
        guard components != nil else {
            return
        }
        
        let host = components!.host
        
        guard host != nil else {
            return
        }
        
        guard let mainController = MBSideMenuController.instance else {
            cachedUrl = url
            return
        }
        
        let parameters = url.parameters
        
//        let pathComponents = url.pathComponents
        
        if let parentViewController = mainController.childNavigationController.viewControllers.last as? MBViewController {
            if host == "teebee" {
                guard let id = parameters["id"] as? String else {
                    return
                }
                
                guard let teebee = Teebee.fetchTeebeeWithTmdbId(Int64(id) ?? 0) else {
                    return
                }
                
                let viewController = parentViewController.storyboard?.instantiateViewController(withIdentifier: "TeebeeDetailsViewController") as! TeebeeDetailsViewController
                viewController.teebee = teebee
                
                parentViewController.showDetailsViewController(viewController)
            }
            else if host == "moobee" {
                guard let id = parameters["id"] as? String else {
                    return
                }
                
                guard let moobee = Moobee.fetchMoobeeWithTmdbId(Int64(id) ?? 0) else {
                    return
                }
                
                let viewController = parentViewController.storyboard?.instantiateViewController(withIdentifier: "MoobeeDetailsViewController") as! MoobeeDetailsViewController
                viewController.moobee = moobee
                
                parentViewController.showDetailsViewController(viewController)
            }
        }


    }
    
    static func parseCachedUrl() {
        guard cachedUrl != nil else {
            return
        }
        
        let url = cachedUrl!
        
        cachedUrl = nil
        
        parse(url)
    }
    
}
