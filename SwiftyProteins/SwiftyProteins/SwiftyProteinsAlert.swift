//
//  SwiftyProteinsAlert.swift
//  SwiftyProteins
//
//  Created by Antoine FEUERSTEIN on 2/15/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import Foundation
import UIKit

class SwiftyProteinsAlert: UIView {
    
    static let margin: CGFloat = 32
    
    static let actionHeight: CGFloat = 50
    static let actionSpacing: CGFloat = 8
    
    static let labelCalcRect: CGRect = {
        return CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width - (SwiftyProteinsAlert.margin * 2 + Content.margin * 2), height: CGFloat.greatestFiniteMagnitude)
    }()
    
    static let cornerRadius: CGFloat = 9
    static let borderWidth: CGFloat = 1
    static let borderColor: CGColor = Design.redSelenium.cgColor
    static let background = Design.grey.withAlphaComponent(0.6)
    
    enum Content {
        case bigTitle(String)
        case title(String)
        case content(String)
        
        func set(label: UILabel) {
            label.numberOfLines = 0
            switch self {
            case .bigTitle(let text):
                label.text = text
                label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
            case .title(let text):
                label.text = text
                label.font = UIFont.systemFont(ofSize: 19, weight: .medium)
            case .content(let text):
                label.text = text
                label.font = UIFont.systemFont(ofSize: 19, weight: .regular)
            }
        }
        static let verticalDistance: CGFloat = 16
        static let margin: CGFloat = 8
    }
    enum Action {
        case destructive(String, () -> ())
        case `default`(String, () -> ())
        
        func set(button: UIButton) {
            switch self {
            case .`default`(let text, _):
                let attr = NSMutableAttributedString.init(string: text)
                
                attr.addAttributes([.foregroundColor: Design.black, .font: UIFont.systemFont(ofSize: 21, weight: .regular)], range: NSMakeRange(0, text.count))
                button.setAttributedTitle(attr, for: .normal)
            case .destructive(let text, _):
                let attr = NSMutableAttributedString.init(string: text)
                
                attr.addAttributes([.foregroundColor: Design.redSelenium, .font: UIFont.systemFont(ofSize: 21, weight: .bold)], range: NSMakeRange(0, text.count))
                button.setAttributedTitle(attr, for: .normal)
            }
        }
    }
    
    var blurEffet: UIVisualEffectView!
    let contents: [SwiftyProteinsAlert.Content]
    let actions: [SwiftyProteinsAlert.Action]
    
    var contentView: UIView!
    var contentViewContent: [UILabel] = []
    
    var actionView: UIStackView!
    var actionViewContent: [SwiftyProteinsAlert.ActionButton] = []
    
    /// contents.count > 0 && actions.count > 0 !!!
    init(contents: [SwiftyProteinsAlert.Content], actions: [SwiftyProteinsAlert.Action]) {
        self.contents = contents
        self.actions = actions
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.clear
        self.blurEffet = UIVisualEffectView.init(frame: self.frame)
        self.blurEffet.effect = nil
        self.addSubview(self.blurEffet)
        
        self.contentView = UIView.init()
        self.addSubview(self.contentView)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.init(item: self.contentView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint.init(item: self.contentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint.init(item: self.contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: SwiftyProteinsAlert.margin).isActive = true
        self.contentView.layer.cornerRadius = SwiftyProteinsAlert.cornerRadius
        self.contentView.layer.borderWidth = SwiftyProteinsAlert.borderWidth
        self.contentView.layer.borderColor = SwiftyProteinsAlert.borderColor
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = SwiftyProteinsAlert.background
        var contentViewHeight: CGFloat = 0
        
        for content in self.contents {
            let label = UILabel.init()
            let labelRect: CGRect
            
            content.set(label: label)
            self.contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.textColor = Design.black
            labelRect = label.textRect(forBounds: SwiftyProteinsAlert.labelCalcRect, limitedToNumberOfLines: 0)
            contentViewHeight += labelRect.height + Content.verticalDistance
            if let topLabel = self.contentViewContent.last {
                NSLayoutConstraint.init(item: label, attribute: .top, relatedBy: .equal, toItem: topLabel, attribute: .bottom, multiplier: 1, constant: Content.verticalDistance).isActive = true
            }
            else {
                NSLayoutConstraint.init(item: label, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1, constant: Content.verticalDistance).isActive = true
            }
            NSLayoutConstraint.init(item: label, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: Content.margin).isActive = true
            NSLayoutConstraint.init(item: label, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: -Content.margin).isActive = true
            NSLayoutConstraint.init(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: labelRect.height).isActive = true
            self.contentViewContent.append(label)
        }
        self.actionView = UIStackView.init()
        self.actionView.alignment = .fill
        self.actionView.distribution = .fillEqually
        self.actionView.axis = .horizontal
        self.actionView.spacing = SwiftyProteinsAlert.actionSpacing
        self.actionView.backgroundColor = SwiftyProteinsAlert.background
        self.addSubview(self.actionView)
        self.actionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.init(item: self.actionView, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: SwiftyProteinsAlert.actionSpacing).isActive = true
        NSLayoutConstraint.init(item: self.actionView, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint.init(item: self.actionView, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint.init(item: self.actionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: SwiftyProteinsAlert.actionHeight).isActive = true
        for action in self.actions {
            let button = ActionButton.init(action: action)
            
            self.actionView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(self.actionButtonSelected(sender:)), for: .touchUpInside)
        }
        if let _ = self.contentViewContent.last { contentViewHeight += Content.verticalDistance }
        NSLayoutConstraint.init(item: self.contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: contentViewHeight).isActive = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func actionButtonSelected(sender: ActionButton) {
        switch sender.action {
        case .`default`(_, let block):
            block()
        case .destructive(_, let block):
            block()
        }
        for actionButton in self.actionViewContent {
            actionButton.removeTarget(self, action: #selector(self.actionButtonSelected(sender:)), for: .touchUpInside)
        }
        self.contentViewContent.removeAll()
        self.actionViewContent.removeAll()
        self.remove()
    }
    
    class ActionButton: UIButton {
        let action: SwiftyProteinsAlert.Action
        
        init(action: SwiftyProteinsAlert.Action) {
            self.action = action
            super.init(frame: CGRect.zero)
            self.backgroundColor = SwiftyProteinsAlert.background
            self.layer.cornerRadius = SwiftyProteinsAlert.cornerRadius
            self.layer.borderWidth = SwiftyProteinsAlert.borderWidth
            self.layer.borderColor = SwiftyProteinsAlert.borderColor
            self.action.set(button: self)
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension SwiftyProteinsAlert {
    
    static let animationDuration: TimeInterval = 0.5
    static let animationOptions: UIViewAnimationOptions = [.curveEaseOut]
    
    func present(in view: UIView) {
        self.contentView.alpha = 0.0
        self.actionView.alpha = 0.0
        view.addSubview(self)
        UIView.animate(withDuration: SwiftyProteinsAlert.animationDuration, delay: 0, options: SwiftyProteinsAlert.animationOptions, animations: {
            self.contentView.alpha = 1.0
            self.actionView.alpha = 1.0
            self.blurEffet.effect = UIBlurEffect.init(style: UIBlurEffectStyle.regular)
        })
    }
    
    func remove() {
        UIView.animate(withDuration: SwiftyProteinsAlert.animationDuration, delay: 0, options: SwiftyProteinsAlert.animationOptions, animations: {
            self.contentView.alpha = 0.0
            self.actionView.alpha = 0.0
            self.blurEffet.effect = nil
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
    
}
