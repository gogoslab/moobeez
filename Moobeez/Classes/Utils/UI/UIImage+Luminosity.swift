//
//  UIImage+Luminosity.swift
//  Moobeez
//
//  Created by Radu Banea on 21/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func luminosity() -> CGFloat {
    
        return luminosity(from: 0, to: Int(self.size.width * self.size.height))
    }
    
    func bottomHalfLuminosity() -> CGFloat {
        
        return luminosity(from: Int(self.size.width * self.size.height) / 2, to: Int(self.size.width * self.size.height))
    }
    
    func luminosity(from:Int, to:Int) -> CGFloat {
        
        var luminosity:CGFloat = 0.0
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        for i in (from...to - 1) {
            
            let pixelInfo: Int = i * 4
            
            let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
            let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
            let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
            
            luminosity += r * 0.299 + g * 0.587 + b * 0.114;
        }
        
        luminosity /= CGFloat(to - from)
        
        return luminosity;
    }
}
