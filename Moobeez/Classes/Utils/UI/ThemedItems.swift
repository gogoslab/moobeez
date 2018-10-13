//
//  ThemedButton.swift
//  Moobeez
//
//  Created by Radu Banea on 02/10/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class ThemedImageView: UIImageView {
    
    @IBInspectable var imageName: String? {
        didSet {
            guard imageName != nil else {
                
                image = nil
                
                return
            }
            
           image = UIImage.init(named: imageName!)
        }
    }

}


class ThemedButton: UIButton {

    @IBInspectable var imageName: String? {
        didSet {
            guard imageName != nil else {
                setImage(nil, for: UIControl.State.normal)
                return
            }
            
            setImage(UIImage.init(named: imageName!), for: UIControl.State.normal)
        }
    }
    
    @IBInspectable var selectedImageName: String? {
        didSet {
            guard selectedImageName != nil else {
                setImage(nil, for: UIControl.State.normal)
                return
            }
            
            setImage(UIImage.init(named: selectedImageName!), for: UIControl.State.selected)
        }
    }

}
