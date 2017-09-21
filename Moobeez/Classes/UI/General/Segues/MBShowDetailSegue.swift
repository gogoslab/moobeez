//
//  MBShowDetailSegue.swift
//  Moobeez
//
//  Created by Radu Banea on 20/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class MBShowDetailSegue: UIStoryboardSegue {

    override func perform() {
        
        guard source is MBViewController else {
            return
        }
        
        (source as! MBViewController).showDetailsViewController(destination)
    }
    
}
