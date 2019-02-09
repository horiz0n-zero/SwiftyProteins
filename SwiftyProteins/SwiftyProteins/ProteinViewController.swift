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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func dismiss() {
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
            self.id = Int(line[1]) ?? 0
            for conect in 2 ..< line.count {
                if let number = Int(line[conect]) {
                    self.connected.append(number)
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
