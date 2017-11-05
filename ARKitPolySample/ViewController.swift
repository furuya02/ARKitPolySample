//
//  ViewController.swift
//  ARKitPolySample
//
//  Created by . SIN on 2017/11/03.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var slider: UISlider!
    var recordingButton: RecordingButton!
    
    var planeNodes:[PlaneNode] = []
    
    enum Mode {
        case flatDetection
        case roomArrangement
        case done
    }
    
    var mode = Mode.flatDetection {
        didSet{
            DispatchQueue.main.async {
                if self.mode == .roomArrangement {
                    self.label.text = "画面をタップして下さい。\n部屋が出現します。"
                } else if self.mode == .done {
                    self.label.text = ""
                    for planeNode in self.planeNodes {
                        planeNode.geometry?.materials.first?.diffuse.contents = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        
        label.text = "平面を検出中です。\nしばらくカメラを動かして\n周囲を撮影してください。"
        
        self.recordingButton = RecordingButton(self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal // <= 平面の検出を有効化する
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mode != .roomArrangement {
            return
        }
        
        mode = .done
        
        let scene = SCNScene(named: "art.scnassets/house.scn")!
        let houseNode = scene.rootNode.childNode(withName: "obj", recursively: true)!
        let scale: CGFloat = CGFloat(slider.value)
        print("scale = \(scale)")
        houseNode.scale = SCNVector3(scale, scale, scale)
        houseNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        houseNode.physicsBody?.restitution = 0.5// 弾み具合　0:弾まない 3:弾みすぎ
        houseNode.physicsBody?.damping = 0.5  // 空気の摩擦抵抗 1でゆっくり落ちる
        houseNode.physicsBody?.categoryBitMask = 1
        
        // スマフォ画面の中央座標
        if let positon = getCenterPosition() {
            houseNode.position = positon
            sceneView.scene.rootNode.addChildNode(houseNode)
        }
    }
    
    func getCenterPosition() -> SCNVector3? {
        let touchLocation = sceneView.center
        let hitResults = sceneView.hitTest(touchLocation, types: [.featurePoint])
        if !hitResults.isEmpty {
            if let hitTResult = hitResults.first {
                return SCNVector3(hitTResult.worldTransform.columns.3.x, hitTResult.worldTransform.columns.3.y + 1, hitTResult.worldTransform.columns.3.z)
            }
        }
        return nil
    }
    
    @IBAction func tapClearbutton(_ sender: Any) {
        if mode == .done {
            if let houseNode = sceneView.scene.rootNode.childNode(withName: "obj", recursively: true) {
                houseNode.removeFromParentNode()
                mode = .roomArrangement
            }
        }
    }
}

extension ViewController : ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if mode == .done {
            return
        }
        
        if mode == .flatDetection {
            mode = .roomArrangement
        }

        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                let panelNode = PlaneNode(anchor: planeAnchor)
                node.addChildNode(panelNode)
                self.planeNodes.append(panelNode)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        if mode == .done {
            return
        }

        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor, let planeNode = node.childNodes[0] as? PlaneNode {
                planeNode.update(anchor: planeAnchor)
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if mode == .done {
            return
        }

        DispatchQueue.main.async {
            if anchor is ARPlaneAnchor {
                node.removeFromParentNode()
            }
        }
    }


}

