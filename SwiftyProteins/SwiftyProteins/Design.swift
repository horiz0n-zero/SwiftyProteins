//
//  Design.swift
//  SwiftyProteins
//
//  Created by Antoine FEUERSTEIN on 1/26/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import Foundation
import UIKit

public struct Design {

    static let backgroundColor = Design.seleniumLight
    
    static let seleniumLight = UIColor.init(red: 254/255, green: 216/255, blue: 148/255, alpha: 1)
    static let selenium = UIColor.init(red: 1, green: 195/255, blue: 136/255, alpha: 1)
    static let seleniumHigh = UIColor.init(red: 254/255, green: 161/255, blue: 45/255, alpha: 1)
    
    static let redSelenium = UIColor.init(red: 1, green: 117/255, blue: 115/255, alpha: 1)
    
    static let grey = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    static let black = UIColor.init(red: 56/255, green: 55/255, blue: 54/255, alpha: 1)
    
    static func getAtomFullName(atom: String) -> String {
        if Locale.current.languageCode! == "fr", let fullName = Design.frAtomFullNames[atom] {
            return fullName
        }
        else if let fullName = Design.enAtomFullNames[atom] {
            return fullName
        }
        return "???"
    }
    
    static let enAtomFullNames: [String : String] = [
        "H": "Hydrogen",
        "HE": "Helium",
        "LI": "Lithium",
        "BE": "Beryllium",
        "B": "Boron",
        "C": "Carbon",
        "N": "Nitrogen",
        "O": "Oxygen",
        "F": "Fluorine",
        "NE": "Neon",
        "NA": "Sodium",
        "MG": "Magnesium",
        "AL": "Aluminum",
        "SI": "Silicon",
        "P": "Phosphorus",
        "S": "Sulfur",
        "CL": "Chlorine",
        "K": "Potassium",
        "CA": "Calcium",
        "SC": "Scandium",
        "TI": "Titanium",
        "V": "Vanadium",
        "CR": "Chrome",
        "MN": "Manganese",
        "FE": "Iron",
        "CO": "Cobalt",
        "NI": "Nickel",
        "CU": "Copper",
        "ZN": "Zinc",
        "GA": "Gallium",
        "GE": "Germanium",
        "AS": "Arsenic",
        "SE": "Selenium",
        "BR": "Brome",
        "KR": "Krypton",
        "RB": "Rubidium",
        "SR": "Strontium",
        "Y": "Yttrium",
        "ZR": "Zirconium",
        "NB": "Niobium",
        "MO": "Molybdenum",
        "TC": "Technetium",
        "RU": "Ruthenium",
        "RH": "Rhodium",
        "PD": "Palladium",
        "AG": "Money",
        "CD": "Cadmium",
        "IN": "Indium",
        "SN": "tin",
        "SB": "Antimony",
        "TE": "Tellurium",
        "I": "Iodine",
        "XE": "Xenon",
        "CS": "Cesium",
        "BA": "Barium",
        "LA": "Lanthanum",
        "CE": "Cerium",
        "PR": "Praseodymium",
        "ND": "neodymium",
        "PM": "Promethium",
        "SM": "Samarium",
        "EU": "Europium",
        "GD": "Gadolinium",
        "TB": "Terbium",
        "DY": "Dysprosium",
        "HO": "Holmium",
        "ER": "Erbium",
        "TM": "Thulium",
        "YB": "Ytterbium",
        "LU": "Lutecium",
        "HF": "Hafnium",
        "TA": "Tantalum",
        "W": "Tungsten",
        "RE": "Rhenium",
        "OS": "Osmium",
        "IR": "Iridium",
        "PT": "Platinum",
        "AU": "Gold",
        "HG": "Mercury",
        "TL": "Thallium",
        "PB": "Lead",
        "BI": "Bismuth",
        "PO": "Polonium",
        "AT": "Astate",
        "RN": "Radon",
        "FR": "Francium",
        "RA": "Radium",
        "AC": "Actinium",
        "TH": "Thorium",
        "PA": "Protactinium",
        "U": "Uranium",
        "NP": "Neptunium",
        "PU": "Plutonium",
        "AM": "Americium",
        "CM": "Curium",
        "BK": "Berkelium",
        "CF": "Californium",
        "ES": "Einsteinium",
        "FM": "Fermium",
        "MD": "Mendelevium",
        "NO": "Nobelium",
        "LR": "Lawrencium",
        "RF": "Rutherfordium",
        "DB": "Dubnium",
        "SG": "Seaborgium",
        "BH": "Bohrium",
        "HS": "Hassium",
        "MT": "Meitnium"
    ]
    
    static let frAtomFullNames: [String : String] = [
        "H": "Hydrogène",
        "HE": "Hélium",
        "LI": "Lithium",
        "BE": "Béryllium",
        "B": "Boron",
        "C": "Carbone",
        "N": "Azote",
        "O": "Oxygène",
        "F": "Fluor",
        "NE": "Néon",
        "NA": "Sodium",
        "MG": "Magnésium",
        "AL": "Aluminium",
        "SI": "Silicium",
        "P": "Phosphore",
        "S": "Soufre",
        "CL": "Chlore",
        "K": "Potassium",
        "CA": "Calcium",
        "SC": "Scandium",
        "TI": "Titane",
        "V": "Vanadium",
        "CR": "Chrome",
        "MN": "Manganèse",
        "FE": "Fer",
        "CO": "Cobalt",
        "NI": "Nickel",
        "CU": "Cuivre",
        "ZN": "Zinc",
        "GA": "Gallium",
        "GE": "Germanium",
        "AS": "Arsenic",
        "SE": "Sélénium",
        "BR": "Brome",
        "KR": "Krypton",
        "RB": "Rubidium",
        "SR": "Strontium",
        "Y": "Yttrium",
        "ZR": "Zirconium",
        "NB": "Niobium",
        "MO": "Molybdène",
        "TC": "Technétium",
        "RU": "Ruthénium",
        "RH": "Rhodium",
        "PD": "Palladium",
        "AG": "Argent",
        "CD": "Cadmium",
        "IN": "Indium",
        "SN": "Étain",
        "SB": "Antimoine",
        "TE": "Tellure",
        "I": "Iode",
        "XE": "Xénon",
        "CS": "Césium",
        "BA": "Baryum",
        "LA": "Lanthane",
        "CE": "Cérium",
        "PR": "Praséodyme",
        "ND": "Néodyme",
        "PM": "Prométhium",
        "SM": "Samarium",
        "EU": "Europium",
        "GD": "Gadolinium",
        "TB": "Terbium",
        "DY": "Dysprosium",
        "HO": "Holmium",
        "ER": "Erbium",
        "TM": "Thulium",
        "YB": "Ytterbium",
        "LU": "Lutécium",
        "HF": "Hafnium",
        "TA": "Tantale",
        "W": "Tungstène",
        "RE": "Rhénium",
        "OS": "Osmium",
        "IR": "Iridium",
        "PT": "Platine",
        "AU": "Or",
        "HG": "Mercure",
        "TL": "Thallium",
        "PB": "Plomb",
        "BI": "Bismuth",
        "PO": "Polonium",
        "AT": "Astate",
        "RN": "Radon",
        "FR": "Francium",
        "RA": "Radium",
        "AC": "Actinium",
        "TH": "Thorium",
        "PA": "Protactinium",
        "U": "Uranium",
        "NP": "Neptunium",
        "PU": "Plutonium",
        "AM": "Américium",
        "CM": "Curium",
        "BK": "Berkélium",
        "CF": "Californium",
        "ES": "Einsteinium",
        "FM": "Fermium",
        "MD": "Mendélévium",
        "NO": "Nobélium",
        "LR": "Lawrencium",
        "RF": "Rutherfordium",
        "DB": "Dubnium",
        "SG": "Seaborgium",
        "BH": "Bohrium",
        "HS": "Hassium",
        "MT": "Meitnérium"
    ]
    
    static func getPCK(atom: String) -> UIColor? {
        if let colors = Design.pckColors[atom] {
            return UIColor.init(red: colors[0] / 255, green: colors[1] / 255, blue: colors[2] / 255, alpha: 1)
        }
        return nil
    }
    static let pckColors: [String: [CGFloat]] =
        ["H": [255,255,255],
        "HE": [217,255,255],
        "LI": [204,128,255],
        "BE": [194,255,0],
        "B": [255,181,181],
        "C": [144,144,144],
        "N": [48,80,248],
        "O": [255,13,13],
        "F": [144,224,80],
        "NE": [179,227,245],
        "NA": [171,92,242],
        "MG": [138,255,0],
        "AL": [191,166,166],
        "SI": [240,200,160],
        "P": [255,128,0],
        "S": [255,255,48],
        "CL": [31,240,31],
        "K": [143,64,212],
        "CA": [61,255,0],
        "SC": [230,230,230],
        "TI": [191,194,199],
        "V": [166,166,171],
        "CR": [138,153,199],
        "MN": [156,122,199],
        "FE": [224,102,51],
        "CO": [240,144,160],
        "NI": [80,208,80],
        "CU": [200,128,51],
        "ZN": [125,128,176],
        "GA": [194,143,143],
        "GE": [102,143,143],
        "AS": [189,128,227],
        "SE": [255,161,0],
        "BR": [166,41,41],
        "KR": [92,184,209],
        "RB": [112,46,176],
        "SR": [0,255,0],
        "Y": [148,255,255],
        "ZR": [148,224,224],
        "NB": [115,194,201],
        "MO": [84,181,181],
        "TC": [59,158,158],
        "RU": [36,143,143],
        "RH": [10,125,140],
        "PD": [0,105,133],
        "AG": [192,192,192],
        "CD": [255,217,143],
        "IN": [166,117,115],
        "SN": [102,128,128],
        "SB": [158,99,181],
        "TE": [212,122,0],
        "I": [148,0,148],
        "XE": [66,158,176],
        "CS": [87,23,143],
        "BA": [0,201,0],
        "LA": [112,212,255],
        "CE": [255,255,199],
        "PR": [217,255,199],
        "ND": [199,255,199],
        "PM": [163,255,199],
        "SM": [143,255,199],
        "EU": [97,255,199],
        "GD": [69,255,199],
        "TB": [48,255,199],
        "DY": [31,255,199],
        "HO": [0,255,156],
        "ER": [0,230,117],
        "TM": [0,212,82],
        "YB": [0,191,56],
        "LU": [0,171,36],
        "HF": [77,194,255],
        "TA": [77,166,255],
        "W": [33,148,214],
        "RE": [38,125,171],
        "OS": [38,102,150],
        "IR": [23,84,135],
        "PT": [208,208,224],
        "AU": [255,209,35],
        "HG": [184,184,208],
        "TL": [166,84,77],
        "PB": [87,89,97],
        "BI": [158,79,181],
        "PO": [171,92,0],
        "AT": [117,79,69],
        "RN": [66,130,150],
        "FR": [66,0,102],
        "RA": [0,125,0],
        "AC": [112,171,250],
        "TH": [0,186,255],
        "PA": [0,161,255],
        "U": [0,143,255],
        "NP": [0,128,255],
        "PU": [0,107,255],
        "AM": [84,92,242],
        "CM": [120,92,227],
        "BK": [138,79,227],
        "CF": [161,54,212],
        "ES": [179,31,212],
        "FM": [179,31,186],
        "MD": [179,13,166],
        "NO": [189,13,135],
        "LR": [199,0,102],
        "RF": [204,0,89],
        "DB": [209,0,79],
        "SG": [217,0,69],
        "BH": [224,0,56],
        "HS": [230,0,46],
        "MT": [235,0,38]]
}
