//
//  ToolboxView.swift
//  Moobeez
//
//  Created by Radu Banea on 21/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

@objc protocol ToolboxViewDelegate {

    @objc optional func toolboxViewWillShow(toolboxView:ToolboxView)
    @objc optional func toolboxViewDidShow(toolboxView:ToolboxView)
    @objc optional func toolboxViewWillHide(toolboxView:ToolboxView)
    @objc optional func toolboxViewDidHide(toolboxView:ToolboxView)

}

class ToolboxView: UIVisualEffectView {

    @IBOutlet var toolboxIndicatorView: UIImageView!
    
    @IBOutlet var showToolboxConstraint: NSLayoutConstraint!
    @IBOutlet var hideToolboxConstraint: NSLayoutConstraint!
    @IBOutlet var moveToolboxConstraint: NSLayoutConstraint!

    @IBOutlet var themedItems: [NSObject]!
    
    var delegate:ToolboxViewDelegate?
    
    private var toolboxStartPoint:CGFloat = 0
    private var delta:CGFloat = 0
    
    private var panGesture:UIPanGestureRecognizer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(recognizer:)))
        addGestureRecognizer(panGesture!)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hideFullToolbox(animated: false)
    }
    
    func applyTheme(lightTheme: Bool) {
        
        for item in themedItems {
            
            if item is UILabel {
                (item as! UILabel).textColor = lightTheme ? UIColor.white : UIColor.black
            }
            
            if item is UITextField {
                (item as! UITextField).textColor = lightTheme ? UIColor.white : UIColor.black
            }
            
            if item is UITextView {
                (item as! UITextView).textColor = lightTheme ? UIColor.white : UIColor.black
            }
            
            if item is ThemedImageView {
                let imageView: ThemedImageView = item as! ThemedImageView
                
                if imageView.imageName != nil {
                    let imageName: String = imageView.imageName!
                    imageView.image = UIImage.init(named: lightTheme ? imageName : imageName + "_dark")
                }                
            }
            
            if item is ThemedButton {
                let button: ThemedButton = item as! ThemedButton
                
                if button.imageName != nil {
                    let imageName: String = button.imageName!
                    button.setImage(UIImage.init(named: lightTheme ? imageName : imageName + "_dark"), for: UIControlState.normal)
                }
                
                if button.selectedImageName != nil {
                    let imageName: String = button.selectedImageName!
                    button.setImage(UIImage.init(named: lightTheme ? imageName : imageName + "_dark"), for: UIControlState.selected)
                }
            }
        }
        
    }
    
    func showFullToolbox(animated:Bool = true) {
        
        self.showToolboxConstraint.isActive = true
        self.hideToolboxConstraint.isActive = false
        self.moveToolboxConstraint.isActive = false
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
            }, completion: { (_) in
                self.toolboxIndicatorView.image = #imageLiteral(resourceName: "toolbox_down_arrow")
            })
        }
        else {
            toolboxIndicatorView.image = #imageLiteral(resourceName: "toolbox_down_arrow")
        }
        
    }
    
    func hideFullToolbox(animated:Bool = true) {
        
        self.showToolboxConstraint.isActive = false
        self.hideToolboxConstraint.isActive = true
        self.moveToolboxConstraint.isActive = false
        
        toolboxIndicatorView.image = #imageLiteral(resourceName: "toolbox_line")
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
            }, completion: { (_) in
                self.toolboxIndicatorView.image = #imageLiteral(resourceName: "toolbox_up_arrow")
            })
        }
        else {
            toolboxIndicatorView.image = #imageLiteral(resourceName: "toolbox_up_arrow")
        }

    }
    
    @objc @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
    
        if recognizer.state == .began {
            toolboxStartPoint = recognizer.translation(in: self.superview).y
            
            self.moveToolboxConstraint.constant = y
            self.moveToolboxConstraint.isActive = true
        }
        else if recognizer.state == .changed {
            
            toolboxIndicatorView.image = #imageLiteral(resourceName: "toolbox_line")
            
            let point:CGFloat = recognizer.translation(in: self.superview).y
            
            delta = point - toolboxStartPoint
            
            self.moveToolboxConstraint.constant += delta
            
            toolboxStartPoint = point
            
            UIView.animate(withDuration: 0.05, animations: {
                self.layoutIfNeeded()
            })
        }
        else if recognizer.state == .ended || recognizer.state == .cancelled {
            
            if fabs(delta) > 1 {
                if delta < 0 {
                    showFullToolbox()
                }
                else {
                    hideFullToolbox()
                }
            }
            else {
                if ((superview?.height)! - y > height / 2) {
                    showFullToolbox()
                }
                else {
                    hideFullToolbox()
                }
            }
        }
    }
    
    
    
}
