//
//  ViewController.swift
//  SwiftyProteins
//
//  Created by Antoine FEUERSTEIN on 1/26/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import UIKit
import SceneKit
import LocalAuthentication

class LoginViewController: UIViewController {

    @IBOutlet var sceneView: SCNView!
    
    @IBOutlet var loginButton: UIButton!
    let loginContext: LAContext = LAContext.init()
    @IBAction func loginButtonTapped(sender: UIButton) {
        self.tryLogin(success: {
            
        }, failure: {
            let alert = UIAlertController.init(title: "Error", message: "a message", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    static var shared: LoginViewController!
    
    var proteinListVC: ProteinListViewController? = nil
    var proteinVC: ProteinViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginViewController.shared = self
        
        self.loginButton.layer.cornerRadius = self.loginButton.frame.height / 2
        self.loginButton.layer.borderColor = Design.borderColor.cgColor
        self.loginButton.layer.borderWidth = 1
        
        let scene = Scene()
        
        self.sceneView.scene = scene
        self.sceneView.backgroundColor = Design.backgroundColor
        self.sceneView.delegate = scene
        self.sceneView.allowsCameraControl = true
        self.sceneView.isPlaying = true
        self.checkLoginButton()
    }

    func dismissChildsVC() {
        if let protein = self.proteinVC {
            protein.dismiss()
            protein.removeFromParentViewController()
        }
        if let proteinList = self.proteinListVC {
            proteinList.dismiss()
            proteinList.removeFromParentViewController()
        }
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
            if can {
                success()
            }
            else {
                failure()
            }
        })
    }
    
}

protocol DismissibleViewController: AnyObject { func dismiss() }
