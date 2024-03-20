//
//  AppDelegate.swift
//  Today
//
//  Created by Radu Banea on 01/11/2018.
//  Copyright © 2018 Gogo's Lab. All rights reserved.
//

import UIKit

class AppDelegate: NSObject {

    static var GroupPath: URL?
    {
        get
        {
            return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.gogoslab.moobeez")
        }
    }
    
}
