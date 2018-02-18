//
//  SettingsManager.swift
//  Moobeez
//
//  Created by Radu Banea on 02/11/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class SettingsManager: NSObject {

    static let shared:SettingsManager = SettingsManager()
    
    private override init() {
        super.init()
    }
    
    var addExtraDay:Bool = true
    
}
