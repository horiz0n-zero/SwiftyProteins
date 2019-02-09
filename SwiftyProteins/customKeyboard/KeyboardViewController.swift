//
//  KeyboardViewController.swift
//  customKeyboard
//
//  Created by Antoine FEUERSTEIN on 2/9/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var keys: [UIButton]!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "KeyboardViewController", bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Design.seleniumLight
        for key in self.keys {
            key.layer.cornerRadius = 4
            key.layer.borderWidth = 1
            key.layer.borderColor = Design.redSelenium.cgColor
            key.backgroundColor = Design.seleniumLight
            key.setTitleColor(Design.redSelenium, for: .normal)
            key.addTarget(self, action: #selector(self.keyTapped(sender:)), for: UIControlEvents.touchUpInside)
        }
    }

    @objc func keyTapped(sender: UIButton) {
        guard let keyContent = sender.titleLabel?.text else {
            return
        }
        func animateKey(sender: UIButton, duration: CFTimeInterval = 0.15) {
            let animation = CABasicAnimation.init(keyPath: #keyPath(CALayer.cornerRadius))
            let cornerRadius = sender.layer.cornerRadius
            let roundedCornerRadius = sender.bounds.height / 2
            
            animation.duration = duration
            animation.fromValue = cornerRadius
            animation.toValue = roundedCornerRadius
            sender.layer.cornerRadius = roundedCornerRadius
            sender.layer.add(animation, forKey: #keyPath(CALayer.cornerRadius))
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(animation.duration), execute: {
                let backAnimation = CABasicAnimation.init(keyPath: #keyPath(CALayer.cornerRadius))
                
                backAnimation.duration = duration
                backAnimation.fromValue = roundedCornerRadius
                backAnimation.toValue = cornerRadius
                sender.layer.cornerRadius = cornerRadius
                sender.layer.add(backAnimation, forKey: #keyPath(CALayer.cornerRadius))
            })
        }
        
        animateKey(sender: sender)
        if keyContent.count > 1 {
            switch keyContent {
            case "CLEAR":
                if let word = self.textDocumentProxy.documentContextBeforeInput, word.count > 0 {
                    for _ in 0 ..< Int(word.count) {
                        self.textDocumentProxy.deleteBackward()
                    }
                }
            case "DELETE":
                self.textDocumentProxy.deleteBackward()
            default:
                self.dismissKeyboard()
                self.resignFirstResponder()
            }
        }
        else {
            self.textDocumentProxy.insertText(keyContent)
        }
    }
    
}
