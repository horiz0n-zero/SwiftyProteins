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
    @IBOutlet var tableViewBottom: NSLayoutConstraint!
    var tableViewBottomStartConstant: CGFloat!
    
    var manager: ProteinDataManager = ProteinDataManager.init()
    var index: Int = 0
    var displayCount: Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.tintColor = Design.selenium
        self.searchBar.layer.cornerRadius = 16
        self.searchBar.barTintColor = Design.selenium
        self.searchBar.returnKeyType = .`continue`
        self.searchBar.delegate = self
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = Design.selenium.cgColor
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.masksToBounds = true
        
        self.tableView.register(UINib.init(nibName: "ProteinTableViewCell", bundle: nil), forCellReuseIdentifier: "ProteinTableViewCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableViewBottomStartConstant = self.tableViewBottom.constant
        self.view.backgroundColor = UIColor.clear
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

    func dismiss() {
        self.searchBar.resignFirstResponder()
    }
}

extension ProteinListViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillAppear(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillDisappear(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @objc func keyboardWillAppear(notification: Notification) {
        guard let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber,
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
            let frame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        self.view.setNeedsLayout()
        UIView.animate(withDuration: TimeInterval(duration.doubleValue), delay: 0, options: UIViewAnimationOptions.init(rawValue: curve.uintValue), animations: {
            self.tableViewBottom.constant = self.tableViewBottomStartConstant + frame.height
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    @objc func keyboardWillDisappear(notification: Notification) {
        guard let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber,
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
                return
        }
        
        self.view.setNeedsLayout()
        UIView.animate(withDuration: TimeInterval(duration.doubleValue), delay: 0, options: UIViewAnimationOptions.init(rawValue: curve.uintValue), animations: {
            self.tableViewBottom.constant = self.tableViewBottomStartConstant
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
