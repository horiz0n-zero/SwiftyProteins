//
//  LoginViewController.swift
//  SwiftyProteins
//
//  Created by Antoine FEUERSTEIN on 1/26/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import UIKit
import SceneKit
import LocalAuthentication

class LoginViewController: UIViewController {
    @IBOutlet weak var proteinsImage: UIImageView!
    @IBOutlet weak var proteinsImageVerticalConstraint: NSLayoutConstraint!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    @IBOutlet var sceneView: SCNView!
    
    @IBOutlet var loginButton: UIButton!
    var loginContext: LAContext = LAContext.init()
    @IBAction func loginButtonTapped(sender: UIButton) {
        self.tryLogin(success: {
            self.showProteinList()
        }, failure: {
            let alert = SwiftyProteinsAlert.init(contents: [.bigTitle(NSLocalizedString("Error", comment: "")), .content(NSLocalizedString("Authentification error", comment: ""))], actions: [.default("OK", { })])
            
            alert.present(in: self.view)
        })
    }
    
    static var shared: LoginViewController!
    
    var proteinListVC: ProteinListViewController? = nil
    var proteinVC: ProteinViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginViewController.shared = self

        self.loginButton.layer.cornerRadius = 8
        self.loginButton.layer.borderWidth = 3
        self.loginButton.layer.borderColor = Design.selenium.cgColor
        self.loginButton.backgroundColor = Design.redSelenium.withAlphaComponent(0.9)
        self.loginButton.setTitleColor(Design.black, for: .normal)
        let scene = Scene()
        
        self.sceneView.scene = scene
        self.sceneView.backgroundColor = Design.backgroundColor
        self.checkLoginButton()
        SceneProteins.shared = SceneProteins.init()
    }

    func dismissChildsVC() {
        if let protein = self.proteinVC {
            protein.dismiss()
            protein.dismiss(animated: true, completion: nil)
            self.proteinVC = nil
        }
        if let proteinList = self.proteinListVC {
            proteinList.dismiss()
            proteinList.dismiss(animated: true, completion: nil)
            self.proteinListVC = nil
        }
        self.checkLoginButton()
    }
    
    func showProteinList() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProteinListViewController") as! ProteinListViewController
        
        vc.modalPresentationStyle = .overCurrentContext
        self.proteinListVC = vc
        loginButton.isHidden = true
        self.proteinsImage.isHidden = true
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @discardableResult func checkLoginButton() -> Bool {
        var error: NSError? = nil
        
        if self.loginContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            loginButton.isHidden = false
            self.proteinsImage.isHidden = false
            return true
        }
        else {
            self.proteinsImage.isHidden = true
            loginButton.isHidden = true
            return false
        }
    }
    func tryLogin(success: @escaping () -> (), failure: @escaping () -> ()) {
        self.loginContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "localize reason", reply: { can, error in
            DispatchQueue.main.async {
                if can {
                    success()
                }
                else {
                    failure()
                }
                self.loginContext = LAContext.init()
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.proteinsImageVerticalConstraint.constant = -self.view.bounds.height / 4
        UIView.animate(withDuration: 1.25, delay: 0, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

protocol DismissibleViewController: AnyObject { func dismiss() }
