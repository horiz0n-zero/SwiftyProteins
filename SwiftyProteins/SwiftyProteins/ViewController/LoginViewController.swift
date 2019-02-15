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

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet var sceneView: SCNView!
    
    @IBOutlet var loginButton: UIButton!
    let loginContext: LAContext = LAContext.init()
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
        
        self.loginButton.layer.cornerRadius = self.loginButton.frame.height / 2
        self.loginButton.layer.borderColor = Design.black.cgColor
        self.loginButton.layer.borderWidth = 2
        self.loginButton.setTitleColor(Design.black, for: .normal)
        
        let scene = Scene()
        
        self.sceneView.scene = scene
        self.sceneView.backgroundColor = Design.backgroundColor
        self.sceneView.allowsCameraControl = true
        self.sceneView.delegate = scene
        self.checkLoginButton()
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
        self.loginButton.isHidden = true
        self.present(vc, animated: true, completion: nil)
    }
    
    @discardableResult func checkLoginButton() -> Bool {
        var error: NSError? = nil
        
        if self.loginContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            self.loginButton.isHidden = false
            return true
        }
        else {
            self.loginButton.isHidden = true
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
            }
        })
    }
}

protocol DismissibleViewController: AnyObject { func dismiss() }
