//
//  UIView+ShortCuts.swift
//  Moobeez
//
//  Created by Radu Banea on 21/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    var x:CGFloat {
        get {
            return frame.origin.x
        }
        set (value) {
            frame.origin.x = value
        }
    }
    
    var y:CGFloat {
        get {
            return frame.origin.y
        }
        set (value) {
            frame.origin.y = value
        }
    }
    
    var width:CGFloat {
        get {
            return frame.size.width
        }
        set (value) {
            frame.size.width = value
        }
    }
    
    var height:CGFloat {
        get {
            return frame.size.height
        }
        set (value) {
            frame.size.height = value
        }
    }
    
    var right:CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
        set (value) {
            frame.origin.x = value - frame.size.width
        }
    }
    
    var bottom:CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
        set (value) {
            frame.origin.y = value - frame.size.height
        }
    }
    
    
    var borderColor:UIColor? {
        get {
            return layer.borderColor != nil ? UIColor(cgColor: layer.borderColor!) : nil
        }
        set (value) {
            layer.borderColor = value != nil ? value?.cgColor : nil
        }
    }
    
    var borderWidth:CGFloat {
        get {
            return layer.borderWidth
        }
        set (value) {
            layer.borderWidth = value
        }
    }
    
    var cornerRadius:CGFloat {
        get {
            return layer.cornerRadius
        }
        set (value) {
            layer.cornerRadius = value
        }
    }
    
    
    
    
    
    
}
