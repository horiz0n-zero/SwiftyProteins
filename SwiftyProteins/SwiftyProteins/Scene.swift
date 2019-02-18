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
    
    static var shared: Scene!
    
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
    var atoms: [SCNNode] = []
    var connections: [SCNNode] = []
}

fileprivate let distanceBackgroundSquare: CGFloat = 5
fileprivate let superBallsCount: Int = 9
fileprivate let randomPositionFactor: CGFloat = 15
fileprivate enum CollisionType: Int {
    case ground = 1
    case superBall = 2
}
extension Scene: SCNPhysicsContactDelegate { // background.Mode
    
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
            let light = SCNLight.init()
            
            light.type = .ambient
            light.color = Design.redSelenium
            light.intensity = 75
            circleNode.light = light
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
 
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.geometry is SCNSphere {
            contact.nodeA.physicsBody?.applyForce(SCNVector3.init(self.randomPosition(), self.randomPosition(), self.randomPosition()), asImpulse: true)
        }
        if contact.nodeB.geometry is SCNSphere {
            contact.nodeB.physicsBody?.applyForce(SCNVector3.init(self.randomPosition(), self.randomPosition(), self.randomPosition()), asImpulse: true)
        }
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

fileprivate let atomRadius: CGFloat = 0.05
fileprivate let connectionRadius: CGFloat = 0.025
fileprivate let scalePosition: Float = 0.10
extension Scene { // molecule.Mode
    
    func initialiseMoleculeMode() {
        func getAtome(from atom: Protein.Atom) -> SCNNode {
            let sphere = SCNSphere.init(radius: atomRadius)
            
            if let color = Design.getPCK(atom: atom.atom) {
                sphere.materials.first?.diffuse.contents = color
            }
            else {
                sphere.materials.first?.diffuse.contents = UIColor.purple
            }
            let ball = SCNNode.init(geometry: sphere)
            
            ball.name = atom.atom
            ball.position = atom.position * scalePosition
            return ball
        }
        func getConection(start startPoint: SCNVector3, end endPoint: SCNVector3) -> SCNNode {
            let vector = endPoint - startPoint
            let len = length(float3(vector))
            let cylinder = SCNCylinder(radius: connectionRadius, height: CGFloat(len))
            
            cylinder.firstMaterial?.diffuse.contents = Design.black
            let node = SCNNode(geometry: cylinder)
            
            node.position = (endPoint + startPoint) / 2
            node.eulerAngles = SCNVector3Make(.pi / 2,
                                              acos((endPoint.z - startPoint.z) / len),
                                              atan2((endPoint.y - startPoint.y), (endPoint.x - startPoint.x)))
            
            return node
        }
        
        self.light.color = UIColor.white
        if let protein = LoginViewController.shared.proteinVC?.protein {
            for atom in protein.atoms {
                let node = getAtome(from: atom)
                
                self.rootNode.addChildNode(node)
                self.atoms.append(node)
            }
            for conect in protein.connections {
                for idConect in conect.connected {
                    let node = getConection(start: self.atoms[conect.id].position, end: self.atoms[idConect].position)
                    
                    self.rootNode.addChildNode(node)
                    self.connections.append(node)
                }
            }
        }
    }
    
    func deinitialiseMoleculeMode() {
        self.light.color = Design.redSelenium
        for atom in self.atoms {
            atom.removeFromParentNode()
        }
        for connection in self.connections {
            connection.removeFromParentNode()
        }
        self.connections.removeAll()
        self.atoms.removeAll()
    }
}

extension Scene: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        glLineWidth(40)
    }
    
}

func *(lhs: SCNVector3, rhs: Float) -> SCNVector3 {
    return SCNVector3.init(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
}
func -(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3.init(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
}
func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3.init(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
}
func /(lhs: SCNVector3, rhs: Float) -> SCNVector3 {
    return SCNVector3.init(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
}



