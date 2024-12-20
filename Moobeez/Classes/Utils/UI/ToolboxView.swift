//
//  ToolboxView.swift
//  Moobeez
//
//  Created by Radu Banea on 21/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
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
    
    @IBOutlet var maskContentView: UIView!
    @IBOutlet var fixedContentView: UIView!
    
    @IBOutlet var showToolboxConstraint: NSLayoutConstraint!
    @IBOutlet var hideToolboxConstraint: NSLayoutConstraint!
    @IBOutlet var moveToolboxConstraint: NSLayoutConstraint!

    @IBOutlet var themedItems: [NSObject]!
    
    @IBOutlet var generalViews: [UIView]!
    
    @IBOutlet var tabButtons: [UIButton]!
    
    var delegate:ToolboxViewDelegate?
    
    var lightTheme:Bool = false
    
    private var toolboxStartPoint:CGFloat = 0
    private var delta:CGFloat = 0
    
    private var panGesture:UIPanGestureRecognizer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(recognizer:)))
        addGestureRecognizer(panGesture!)
        cells = generalViews
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hideFullToolbox(animated: false)
        
        effect = UIBlurEffect(style: SettingsManager.shared.lightTheme ? .extraLight : .dark)
        applyTheme(lightTheme: !SettingsManager.shared.lightTheme)
    }
    
    func applyTheme(lightTheme: Bool) {
        
        self.lightTheme = lightTheme
        
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
                    button.setImage(UIImage.init(named: lightTheme ? imageName : imageName + "_dark"), for: UIControl.State.normal)
                }
                
                if button.selectedImageName != nil {
                    let imageName: String = button.selectedImageName!
                    button.setImage(UIImage.init(named: lightTheme ? imageName : imageName + "_dark"), for: UIControl.State.selected)
                }
            }
            
            if item is UIDatePicker {
                let datePicker: UIDatePicker = item as! UIDatePicker
                
                datePicker.setValue(lightTheme ? UIColor.white : UIColor.black, forKeyPath: "textColor")
            }
        }
    }
    
    var isVisible:Bool {
        get {
            return self.hideToolboxConstraint.isActive == false
        }
    }
    
    func showFullToolbox(animated:Bool = true) {
        
        self.showToolboxConstraint.isActive = true
        self.hideToolboxConstraint.isActive = false
        self.moveToolboxConstraint.isActive = false
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
               self.superview!.layoutIfNeeded()
            }, completion: { (_) in
                self.toolboxIndicatorView.image = !self.lightTheme ? #imageLiteral(resourceName: "toolbox_down_arrow") : #imageLiteral(resourceName: "toolbox_down_arrow_light")
            })
        }
        else {
            toolboxIndicatorView.image = !lightTheme ? #imageLiteral(resourceName: "toolbox_down_arrow") : #imageLiteral(resourceName: "toolbox_down_arrow_light")
        }
        
    }
    
    func hideFullToolbox(animated:Bool = true) {
        
        self.showToolboxConstraint.isActive = false
        self.hideToolboxConstraint.isActive = true
        self.moveToolboxConstraint.isActive = false
        
        toolboxIndicatorView.image = !lightTheme ? #imageLiteral(resourceName: "toolbox_line") : #imageLiteral(resourceName: "toolbox_line_light")
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.superview!.layoutIfNeeded()
            }, completion: { (_) in
                self.toolboxIndicatorView.image = !self.lightTheme ? #imageLiteral(resourceName: "toolbox_up_arrow") : #imageLiteral(resourceName: "toolbox_up_arrow_light")
            })
        }
        else {
            toolboxIndicatorView.image = !self.lightTheme ? #imageLiteral(resourceName: "toolbox_up_arrow") : #imageLiteral(resourceName: "toolbox_up_arrow_light")
        }

    }
    
    @objc @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
    
        if recognizer.state == .began {
            toolboxStartPoint = recognizer.translation(in: self.superview).y
            
            self.moveToolboxConstraint.constant = maskContentView.frame.height
            self.moveToolboxConstraint.isActive = true
        }
        else if recognizer.state == .changed {
            
            toolboxIndicatorView.image = !lightTheme ? #imageLiteral(resourceName: "toolbox_line") : #imageLiteral(resourceName: "toolbox_line_light")
            
            let point:CGFloat = recognizer.translation(in: self.superview).y
            
            delta = point - toolboxStartPoint
            
            self.moveToolboxConstraint.constant = self.moveToolboxConstraint.constant - delta
            
            toolboxStartPoint = point
            
            UIView.animate(withDuration: 0.05, animations: {
                self.superview!.layoutIfNeeded()
            })
        }
        else if recognizer.state == .ended || recognizer.state == .cancelled {
            
            if abs(delta) > 1 {
                if delta < 0 {
                    showFullToolbox()
                }
                else {
                    hideFullToolbox()
                }
            }
            else {
                if (maskContentView.frame.height > fixedContentView.frame.height / 2) {
                    showFullToolbox()
                }
                else {
                    hideFullToolbox()
                }
            }
        }
    }
    
    var cells:[UIView]? {
        
        willSet {
            if cells != nil {
                for cell:UIView in cells! {
                    cell.isHidden = true
                }
            }
        }
        didSet {
            if cells != nil {
                for cell:UIView in cells! {
                    cell.isHidden = false
                    cell.backgroundColor = UIColor.clear
                    
                    if cell.superview == nil {
                        if let stackView = self.fixedContentView as? UIStackView {
                            stackView.addArrangedSubview(cell)
                        }
                    }
                }
            }
        }
    }
    
}
