//
//  SearchBar.swift
//  Moobeez
//
//  Created by Radu Banea on 11/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class SearchBar: UISearchBar {

    @IBInspectable var placeholderColor: UIColor? {
        didSet {
            
            let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
            let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
            textFieldInsideSearchBarLabel?.textColor = placeholderColor
        }
    }
    
    @IBInspectable var textColor: UIColor? {
        didSet {
            let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
            textFieldInsideSearchBar?.textColor = textColor
        }
    }
    
    @IBInspectable var magnifyingGlassColor: UIColor? {
        
        didSet {
            
            if let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField,
                let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
                
                //Magnifying glass
                glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                glassIconView.tintColor = magnifyingGlassColor
                
            }
        }
    }
}
