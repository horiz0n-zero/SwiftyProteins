//
//  ProteinViewController.swift
//  SwiftyProteins
//
//  Created by Antoine FEUERSTEIN on 2/4/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class ProteinViewController: UIViewController, DismissibleViewController {
    
    var content: String!
    var ligand: String!
    var protein: Protein!
    
    @IBOutlet var bottomView: UIView!
    @IBOutlet var bottomButtons: [UIButton]!
    @IBOutlet var proteinContentView: SCNView!
    
    @IBOutlet var atomView: UIView!
    @IBOutlet var atomViewLabel: UILabel!
    @IBOutlet var atomViewCentering: NSLayoutConstraint!
    
    @IBOutlet var atomExtensionView: UIView!
    @IBOutlet var atomExtensionViewLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.atomView.layer.cornerRadius = self.atomView.bounds.height / 2
        self.atomView.backgroundColor = Design.selenium
        self.atomView.alpha = 0.0
        self.atomExtensionView.layer.cornerRadius = self.atomExtensionView.bounds.height / 2
        self.atomExtensionView.backgroundColor = Design.selenium
        self.atomExtensionView.alpha = 0.0
        for button in self.bottomButtons {
            if let image = button.imageView?.image {
                let template = image.withRenderingMode(.alwaysTemplate)
                
                button.setImage(template, for: .normal)
                button.tintColor = Design.black
            }
        }
        self.bottomView.backgroundColor = Design.selenium
        
        self.protein = Protein.init(content: self.content)
        if let sceneProtein = SceneProteins.shared {
            self.proteinContentView.backgroundColor = Design.seleniumLight
            self.proteinContentView.scene = sceneProtein
            self.proteinContentView.allowsCameraControl = true
            self.proteinContentView.antialiasingMode = .multisampling4X
            sceneProtein.initialiseMoleculeMode()
        }
        else {
            let alert = SwiftyProteinsAlert.init(contents: [.bigTitle("Error"), .content("unknow error occured.")], actions: [.destructive("OK", { self.deleteAction(self.bottomButtons[1]) })])
            
            alert.present(in: self.view)
        }
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        LoginViewController.shared.proteinVC = nil
        self.dismiss()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func shareAction() {
        let image = self.proteinContentView.snapshot()
        let shareViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        present(shareViewController, animated: true, completion: nil)
        if let pop = shareViewController.popoverPresentationController {
            pop.sourceView = self.bottomButtons.first!
            pop.sourceRect = self.bottomButtons.first!.bounds
            pop.permittedArrowDirections = .down
        }
    }
    
    func dismiss() {
        LoginViewController.shared.proteinListVC?.unhideElements()
        LoginViewController.shared.sceneView.play(nil)
        (self.proteinContentView.scene as? SceneProteins)?.deinitialiseMoleculeMode()
    }
    
    var selection: Bool = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            self.selection = true
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.selection = false
    }
    fileprivate let atomViewDuration: TimeInterval = 0.3
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1, self.selection, let touch = touches.first {
            let location = touch.location(in: self.view)
            
            if self.proteinContentView.point(inside: location, with: event) {
                for result in self.proteinContentView.hitTest(location, options: nil) {
                    if let atom = result.node.name {
                        func transition(label: UILabel, text: String) {
                            let anim = CATransition.init()
                            
                            anim.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
                            anim.type = kCATransitionFade
                            anim.duration = atomViewDuration
                            label.layer.add(anim, forKey: kCATransitionFade)
                            label.text = text
                        }
                        func appear(on: UIView) {
                            UIView.animate(withDuration: atomViewDuration, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                                on.alpha = 1.0
                            }, completion: nil)
                        }
                        
                        if self.atomView.alpha == 0.0 {
                            appear(on: self.atomView)
                        }
                        if self.atomViewLabel.text != atom {
                            transition(label: self.atomViewLabel, text: atom)
                        }
                        if self.atomExtensionView.alpha == 0.0 {
                            appear(on: self.atomExtensionView)
                        }
                        let atomFullName = Design.getAtomFullName(atom: atom)
                        
                        if self.atomExtensionViewLabel.text != atomFullName {
                            transition(label: self.atomExtensionViewLabel, text: atomFullName)
                            let atomExtensionLabelRect = self.atomExtensionViewLabel.textRect(forBounds: CGRect.init(origin: .zero, size: .init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)), limitedToNumberOfLines: 0)
                            
                            UIView.animate(withDuration: atomViewDuration, delay: 0, options: [.curveEaseOut], animations: {
                                self.atomViewCentering.constant = atomExtensionLabelRect.width + 50
                                self.atomExtensionView.layer.cornerRadius = self.atomExtensionView.bounds.height / 2
                                self.atomView.layer.cornerRadius = self.atomView.bounds.height / 2
                                self.view.layoutIfNeeded()
                            }, completion: nil)
                        }
                        break
                    }
                }
            }
            self.selection = false
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.selection = false
    }
    
}

struct Protein {
    
    struct Atom {
        var atom: String
        var position: SCNVector3
        var id: Int
        
        init(atom: String, position: SCNVector3, id: Int) {
            self.atom = atom
            self.position = position
            self.id = id
        }
        
        @inline (__always) static func from(line: [Substring]) -> Atom? {
            if line.count != 12 {
                return nil
            }
            
            return Atom.init(atom: String(line[11]), position: SCNVector3.init(Double(line[6]) ?? 0, Double(line[7]) ?? 0, Double(line[8]) ?? 0), id: Int(line[1]) ?? 0)
        }
    }
    var atoms: [Atom] = []
    
    struct Conect {
        var id: Int
        var connected: [Int] = []
        
        init(line: [Substring]) {
            if let id = Int(line[1]) {
                self.id = id - 1
            }
            else {
                self.id = 0
            }
            for conect in 2 ..< line.count {
                if let number = Int(line[conect]) {
                    self.connected.append(number - 1)
                }
            }
        }
    }
    var connections: [Conect] = []
    
    init(content: String) {
        let lines = content.split(separator: "\n")
        
        for line in lines {
            let elements = line.split(separator: " ")
            guard let firstElement = elements.first else {
                break
            }
            
            if firstElement == "ATOM" {
                if let atom = Atom.from(line: elements) {
                    self.atoms.append(atom)
                }
            }
            else if firstElement == "CONECT", elements.count >= 3 {
                self.connections.append(Protein.Conect.init(line: elements))
            }
            else {
                break
            }
        }
    }
}

extension ProteinListViewController {
    
    func hideElements() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 0.0
        }) { _ in
            self.view.isUserInteractionEnabled = false
        }
    }
    
    func unhideElements() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 1.0
        }) { _ in
            self.view.isUserInteractionEnabled = true
        }
    }
}
