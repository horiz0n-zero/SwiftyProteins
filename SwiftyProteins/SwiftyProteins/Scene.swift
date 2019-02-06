//
//  Scene.swift
//  SwiftyProteins
//
//  Created by Antoine FEUERSTEIN on 1/26/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import Foundation
import SceneKit

class Scene: SCNScene {
    
    static var shared: SCNScene!
    
    var camera: SCNCamera!
    var light: SCNLight!
    var node: SCNNode!
    
    var circles: [SCNNode] = []
    
    override init() {
        super.init()
        Scene.shared = self
        self.camera = SCNCamera.init()
        self.node = SCNNode.init()
        self.light = SCNLight.init()
        
        self.light.color = Design.testColor
        self.light.type = .omni
        self.node.camera = camera
        self.node.light = self.light
        self.node.position = SCNVector3.init(0, 0, 3)
        self.rootNode.addChildNode(node)
        
        for index in 0...10 {
            let circle = self.createCirle(radius: 0.01)
            
            circle.position = SCNVector3.init(cos(CGFloat(index) / 10), sin(-(CGFloat(index) / 10)), 0)
            self.rootNode.addChildNode(circle)
        } 
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createCirle(radius: CGFloat = 0.5) -> SCNNode {
        let sphere = SCNSphere.init(radius: radius)
        let node = SCNNode.init(geometry: sphere)
        
        sphere.firstMaterial?.diffuse.contents = Design.testColor
        return node
    }
    
}

extension Scene: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let value = sin(time)
        let value1 = cos(time)
        
        self.node.position = SCNVector3.init(value, value1, 3)
    }
    
}
