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
    
    //@IBOutlet var settingsView: UIView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        for button in self.bottomButtons {
            if let image = button.imageView?.image {
                let template = image.withRenderingMode(.alwaysTemplate)
                
                button.setImage(template, for: .normal)
                button.tintColor = Design.black
            }
        }
        self.bottomView.backgroundColor = Design.selenium
        //self.settingsView.backgroundColor = UIColor.clear
        
        self.protein = Protein.init(content: self.content)
        print(self.ligand)
        for atom in self.protein.atoms {
            print(atom)
        }
        for conect in self.protein.connections {
            print(conect)
        }
        Scene.shared.mode = .molecule
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        LoginViewController.shared.proteinVC = nil
        self.dismiss()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func shareAction() {
        //blet alert = SwiftyProteinsAlert.init(contents: [.title("Please wait ...")], actions: [])
        
        //alert.present(in: self.view)
        let image = LoginViewController.shared.sceneView.snapshot()
        let shareViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        present(shareViewController, animated: true, completion: nil)//{
            //alert.remove()
        //})
    }
    
    func dismiss() {
        LoginViewController.shared.proteinListVC?.unhideElements()
        Scene.shared.mode = .background
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
