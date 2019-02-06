//
//  ProteinListViewController.swift
//  SwiftyProteins
//
//  Created by Antoine FEUERSTEIN on 2/4/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import Foundation
import UIKit

class ProteinListViewController: UIViewController, DismissibleViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var manager: ProteinDataManager = ProteinDataManager.init()
    var index: Int = 0
    var displayCount: Int = 5 // 50 !!! bobo
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.tintColor = Design.borderColor
        self.searchBar.layer.cornerRadius = 16
        self.searchBar.barTintColor = Design.borderColor
        self.searchBar.returnKeyType = .`continue`
        self.searchBar.delegate = self
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = Design.borderColor.cgColor
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.masksToBounds = true
        
        self.tableView.register(UINib.init(nibName: "ProteinTableViewCell", bundle: nil), forCellReuseIdentifier: "ProteinTableViewCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.backgroundColor = Design.backgroundColor
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.index + self.displayCount >= ProteinDataManager.ligands.count {
            return ProteinDataManager.ligands.count - self.index
        }
        return self.displayCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ProteinTableViewCell", for: indexPath) as! ProteinTableViewCell
        
        cell.fill(ligand: ProteinDataManager.ligands[indexPath.row + self.index], manager: self.manager)
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let compare = searchText.uppercased()
        
        self.index = 0
        for element in ProteinDataManager.ligands {
            if element > compare {
                break
            }
            self.index = self.index + 1
        }
        self.tableView.reloadSections(IndexSet.init(integersIn: 0...0), with: .automatic)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func dismiss() { }
}

