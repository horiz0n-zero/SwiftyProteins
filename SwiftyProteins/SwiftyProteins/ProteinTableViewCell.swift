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
        // self.ligandImage.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        self.ligandLabel.textColor = Design.textLightColor
        self.ligandDownloadProgress.progress = 0
        //self.ligandDownloadProgress.tintColor = Design.borderColor
    }
    
    func fill(ligand: String, manager: ProteinDataManager) {
        self.ligand = ligand
        self.ligandLabel.text = ligand
        manager.proteinFile(ligand: ligand, success: { forLigand, data in
            DispatchQueue.main.async {
                if forLigand == self.ligand {
                    self.ligandDownloadProgress.progress = 1
                }
            }
        }, failure: { error in
            print("# error ", self.ligand, error)
        }, progress: { forLigand, fraction in
            DispatchQueue.main.async {
                if forLigand == self.ligand {
                    //self.ligandDownloadProgress.setProgress(Float(fraction), animated: false)
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
        }, failure: { error in print("# error \(self.ligand) ", error) }, progress: { _, _ in })
    }
}
