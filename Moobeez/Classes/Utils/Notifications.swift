//
//  Constants.swift
//  Moobeez
//
//  Created by Radu Banea on 02/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let SideMenuWillAppearNotification = Notification.Name("SideMenuWillAppearNotification")
    static let SideMenuWillDissappearNotification = Notification.Name("SideMenuWillDissappearNotification")

}

typealias EmptyHandler = () -> ()
typealias CompleteHandler = (_ complete: Bool) -> ()

