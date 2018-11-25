//
//  MBSideMenuSegue.swift
//  Moobeez
//
//  Created by Radu Banea on 02/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import UIKit

class MBSideMenuSegue: UIStoryboardSegue {

    override func perform() {
        (source as! MBSideMenuController).showViewController(destination)
    }
    
}
