//
//  ShowMoobeeSegue.swift
//  Moobeez
//
//  Created by Radu Banea on 20/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class ShowDetailsSegue: UIStoryboardSegue {

    override func perform() {
     
        (source as! MoobeezViewController).showDetailsViewController(viewController: destination as! MoobeeDetailsViewController)
        
    }
}
