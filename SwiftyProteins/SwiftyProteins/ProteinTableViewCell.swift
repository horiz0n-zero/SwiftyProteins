//
//  ProteinTableViewCell.swift
//  SwiftyProteins
//
//  Created by Antoine FEUERSTEIN on 2/6/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import UIKit

class ProteinTableViewCell: UITableViewCell {

    @IBOutlet var ligandLabel: UILabel!
    @IBOutlet var ligandImage: UIImageView!
    @IBOutlet var ligandDownloadProgress: UIProgressView!
    
    var ligand: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ligandImage.layer.cornerRadius = 8
        self.ligandImage.layer.masksToBounds = true
        self.ligandLabel.textColor = Design.black
        self.ligandDownloadProgress.progress = 0
        self.ligandDownloadProgress.tintColor = Design.selenium
    }
    
    func fill(ligand: String, manager: ProteinDataManager) {
        self.ligand = ligand
        self.ligandLabel.text = ligand
        manager.proteinFile(ligand: ligand, success: { forLigand, data in
            DispatchQueue.main.async {
                if forLigand == self.ligand {
                    self.ligandDownloadProgress.tintColor = Design.selenium
                    self.ligandDownloadProgress.progress = 1
                }
            }
        }, failure: { forLigand, _ in
            DispatchQueue.main.async {
                if forLigand == self.ligand {
                    self.ligandDownloadProgress.tintColor = Design.redSelenium
                    self.ligandDownloadProgress.progress = 1
                }
            }
        }, progress: { forLigand, fraction in
            DispatchQueue.main.async {
                if forLigand == self.ligand {
                    self.ligandDownloadProgress.tintColor = Design.selenium
                    self.ligandDownloadProgress.progress = Float(fraction)
                }
            }
        })
        manager.proteinImage(ligand: ligand, success: { forLigand, data in
            DispatchQueue.main.async {
                if forLigand == ligand {
                    self.ligandImage.image = UIImage.init(data: data)
                }
            }
        }, failure: { _, _ in }, progress: { _, _ in })
    }
}
