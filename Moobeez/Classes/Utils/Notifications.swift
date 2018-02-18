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
    
    static let BeeDidChangeNotification = Notification.Name("BeeDidChangeNotification")
    
    static let MoobeezDidChangeNotification = Notification.Name("MoobeezDidChangeNotification")
    static let TeebeezDidChangeNotification = Notification.Name("TeebeezDidChangeNotification")

}

typealias EmptyHandler = () -> ()
typealias CompleteHandler = (_ complete: Bool) -> ()

