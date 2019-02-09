//
//  Wording.swift
//  SwiftyProteins
//
//  Created by Antoine FEUERSTEIN on 2/9/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import Foundation
import UIKit

class Wording: NSObject {
    
    static let shared: Wording = Wording()
    
    var words: [String: String] = ["error": "Erreur",
                                   "error.authentification": "Mauvaise identification biométrique.",
                                   "error.requiredfile": "Le fichier requis n'a pas encore pu être télécharger",
                                   "error.fileempty": "Le fichier est vide et ne peux malheuresement pas être lu.",
                                   "ok": "ok"]
    
    override init() {
        super.init()
    }
    
    subscript(key: String) -> String {
        return self.words[key]!
    }
    
}
