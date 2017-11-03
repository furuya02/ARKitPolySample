//
//  PlaneNode.swift
//  ARKitPolySample
//
//  Created by . SIN on 2017/11/03.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

import ARKit

class PlaneNode: SCNNode {
    init(anchor: ARPlaneAnchor) {
        super.init()
        
        //geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        geometry = SCNPlane(width: 100, height: 100) // サイズは100m×100mとする

        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        geometry?.materials = [planeMaterial]
        SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: geometry!, options: nil))
        physicsBody?.categoryBitMask = 2
        
    }
    
    func update(anchor: ARPlaneAnchor) {
        (geometry as! SCNPlane).width = 100//CGFloat(anchor.extent.x)
        (geometry as! SCNPlane).height = 100//CGFloat(anchor.extent.z)
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
