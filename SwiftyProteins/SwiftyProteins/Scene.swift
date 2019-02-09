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
    
    enum Mode {
        case background
        case molecule
    }
    var mode: Scene.Mode = .background {
        didSet {
            if oldValue != self.mode {
                switch self.mode {
                case .background:
                    self.deinitialiseMoleculeMode()
                    self.initialiseBackgroundMode()
                case .molecule:
                    self.deinitialiseBackgroundMode()
                    self.initialiseMoleculeMode()
                }
            }
        }
    }
    
    override init() {
        super.init()
        Scene.shared = self
        
        self.camera = SCNCamera.init()
        self.node = SCNNode.init()
        self.light = SCNLight.init()
        
        self.light.color = Design.redSelenium
        self.light.type = .omni
        self.node.camera = camera
        self.node.light = self.light
        self.node.position = SCNVector3.init(0, 0, 3)
        self.rootNode.addChildNode(node)
    
        self.physicsWorld.contactDelegate = self
        self.initialiseBackgroundMode()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // background.Mode
    var boxContainers: [SCNNode] = []
    var spheres: [SCNNode] = []
    
    // molecule.Mode
    
}

fileprivate let distanceBackgroundSquare: CGFloat = 5
fileprivate let superBallsCount: Int = 9
fileprivate let randomPositionFactor: CGFloat = 15
fileprivate enum CollisionType: Int {
    case ground = 1
    case superBall = 2
}
extension Scene { // background.Mode
    
    func initialiseBackgroundMode() {
        func rectangle() -> SCNNode {
            let rect = SCNBox.init(width: distanceBackgroundSquare, height: distanceBackgroundSquare, length: distanceBackgroundSquare, chamferRadius: 0)
            
            rect.materials.first?.diffuse.contents = UIColor.clear
            let node = SCNNode.init(geometry: rect)
            
            node.physicsBody = SCNPhysicsBody.init(type: .static, shape: SCNPhysicsShape.init(node: node, options: nil))
            node.physicsBody?.categoryBitMask = CollisionType.ground.rawValue
            node.physicsBody?.collisionBitMask = CollisionType.superBall.rawValue
            node.physicsBody?.contactTestBitMask = CollisionType.superBall.rawValue
            return node
        }
        
        for position in [SCNVector3.init(0, 0, -distanceBackgroundSquare),
                         SCNVector3.init(0, 0, distanceBackgroundSquare),
                         SCNVector3.init(0, -distanceBackgroundSquare, 0),
                         SCNVector3.init(0, distanceBackgroundSquare, 0),
                         SCNVector3.init(-distanceBackgroundSquare, 0, 0),
                         SCNVector3.init(distanceBackgroundSquare, 0, 0)] {
            let node = rectangle()
            
            node.position = position
            self.boxContainers.append(node)
            self.rootNode.addChildNode(node)
        }
        
        func circle() -> SCNNode {
            let circle = SCNSphere.init(radius: 0.1)
            
            circle.materials.first?.diffuse.contents = Design.redSelenium
            let circleNode = SCNNode.init(geometry: circle)
            
            circleNode.position = SCNVector3.init(CGFloat(drand48()) / 2, CGFloat(drand48()) / 2, 0)
            circleNode.physicsBody = SCNPhysicsBody.init(type: .dynamic, shape: SCNPhysicsShape.init(geometry: circle, options: nil))
            circleNode.physicsBody?.categoryBitMask = CollisionType.superBall.rawValue
            circleNode.physicsBody?.collisionBitMask = CollisionType.ground.rawValue
            circleNode.physicsBody?.contactTestBitMask = CollisionType.ground.rawValue
            //circleNode.physicsBody?.friction = 23
            //circleNode.physicsBody?.mass = 1
            //circleNode.physicsBody?.restitution = 10
            
            let light = SCNLight.init()
            
            light.type = .ambient
            light.color = Design.redSelenium
            light.intensity = 75
            circleNode.light = light
            /*
            circleNode.runAction(SCNAction.repeatForever(SCNAction.sequence([SCNAction.run({ node in
                
                func randomPosition() -> CGFloat {
                    let mutiple: CGFloat = 20
                    let diff = mutiple / 2
                    
                    return CGFloat(drand48()) * mutiple - diff
                }
                
                node.physicsBody?.applyForce(SCNVector3.init(randomPosition(), randomPosition(), randomPosition()), asImpulse: true)
            }), SCNAction.wait(duration: 1, withRange: 0.5)])))*/
            return circleNode
        }
        
        for _ in 0 ... superBallsCount {
            let node = circle()
            
            self.spheres.append(node)
            self.rootNode.addChildNode(node)
            node.physicsBody?.applyForce(SCNVector3.init(self.randomPosition(), self.randomPosition(), self.randomPosition()), asImpulse: true)
        }
    }
    
    @inline (__always) fileprivate func randomPosition() -> CGFloat {
        return CGFloat(drand48()) * randomPositionFactor - randomPositionFactor / 2
    }
    
    func deinitialiseBackgroundMode() {
        for sphere in self.spheres {
            sphere.removeFromParentNode()
        }
        self.spheres.removeAll()
        for box in self.boxContainers {
            box.removeFromParentNode()
        }
        self.boxContainers.removeAll()
    }
}
extension Scene: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.geometry is SCNSphere {
            contact.nodeA.physicsBody?.applyForce(SCNVector3.init(self.randomPosition(), self.randomPosition(), self.randomPosition()), asImpulse: true)
        }
        if contact.nodeB.geometry is SCNSphere {
            contact.nodeB.physicsBody?.applyForce(SCNVector3.init(self.randomPosition(), self.randomPosition(), self.randomPosition()), asImpulse: true)
        }
    }
    
}

extension Scene { // molecule.Mode
    
    func initialiseMoleculeMode() {
        
    }
    
    func deinitialiseMoleculeMode() {
        
    }
}

extension Scene: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
}















