//
//  PictureCollectionCell.swift
//  MinderaGallery
//
//  Created by Quentin Beaudouin on 14/03/2018.
//  Copyright © 2016 Quentin Beaudouin. All rights reserved.
//

import UIKit


/* COMMENT:
 * I created this custom Alert as I prefered to have access to the control center to enable/disable
 * internet connection. It actually provide a better UI integration and a nice Mindera purple color, though
 * it add a bit of code in a small project
 */

class Popup: UIView, CAAnimationDelegate {
    
    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    
    var tapBackgroundToDismiss = true
    var leftAction:(() -> (Void))?
    var rightAction:(() -> (Void))?

//    var layouted = false
    
    
    override func awakeFromNib() {
    
        super.awakeFromNib()
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        mainView.layer.cornerRadius = 4
        let shadowPath:UIBezierPath  = UIBezierPath.init(roundedRect: (mainView.bounds), cornerRadius: 4)
        
        mainView.layer.shadowRadius = 20
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOpacity = 0.3
        mainView.layer.shadowOffset = CGSize(width: 0, height: 6)
        mainView.layer.shadowPath = shadowPath.cgPath
        mainView.clipsToBounds = false
        
        leftButton.layer.cornerRadius = 17
        leftButton.layer.borderColor = UIColor.white.cgColor
        leftButton.layer.borderWidth = 1
        
        if rightButton != nil {
            rightButton.layer.cornerRadius = 17
            rightButton.layer.borderColor = UIColor.white.cgColor
            rightButton.layer.borderWidth = 1
        }
        
        
        
    }
    
    func setup(title:String, message:String, leftButtonTitle:String?, rightButtonTitle:String? = nil) {
        
        titleLbl.text = title
        messageLabel.text = message
        
        if leftButtonTitle != nil {
            leftButton.setTitle(leftButtonTitle, for: .normal)
        }
        else {
            buttonView.removeFromSuperview()
        }
        if rightButtonTitle != nil {
            rightButton.setTitle(rightButtonTitle, for: .normal)
        }
        else {
            rightButton.removeFromSuperview()
        }
        
        
        
        
    }
    
    
    func showInWindow(_ window:UIWindow, confetti:Bool = false) {

        frame = window.bounds
        
        mainView.transform = CGAffineTransform(translationX: 0, y: -(mainView.frame.size.height + mainView.frame.origin.y / 10))
        
        self.alpha = 0
        
        window.addSubview(self)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.alpha = 1
            self.mainView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)


    }
    
    
    @IBAction func clickLeftButton(_ sender: UIButton) {
        hide(good: true)
        leftAction?()
        
    }

    @IBAction func clickRightButton(_ sender: UIButton) {
        hide(good: false)
        rightAction?()
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        if tapBackgroundToDismiss {
            hide(good: false)
            rightAction?()
        }
        
    }
    
    func hide(good:Bool){
        if good {
            
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                    self.mainView.transform = CGAffineTransform(translationX: 0, y: self.mainView.frame.size.height / 7)
                })
                UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.8, animations: {
                    self.mainView.transform = CGAffineTransform(translationX: 0, y: -(self.mainView.frame.size.height + self.mainView.frame.origin.y/4))
                    self.alpha = 0
                })
                }, completion: { (finished) in
                    self.removeFromSuperview()
            })
        }
        else {
            
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear, animations: {
                
                let rotate = CGFloat.pi / 24.0 * (CGFloat(arc4random_uniform(3)) + 1.5)
                
                
                self.mainView.transform = CGAffineTransform(translationX: 0, y: self.mainView.frame.size.height + self.mainView.frame.origin.y / 4).rotated(by: rotate)
                self.alpha = 0
                }, completion: { (finished) in
                    self.removeFromSuperview()

            })
        }
        
    }

}
