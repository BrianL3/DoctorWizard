//
//  GameViewController.swift
//  DoctorWizard
//
//  Created by nacnud on 1/26/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import UIKit
import SpriteKit
class GameViewController: UIViewController {
    override func viewDidLoad() {
    super.viewDidLoad()
    let scene =
    GameScene(size:CGSize(width: 2048, height: 1536))
    let skView = SKView(frame: self.view.frame)
    self.view.addSubview(skView)
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .AspectFill
    skView.presentScene(scene)
    }
    

    
    override func prefersStatusBarHidden() -> Bool  {
        return true
    }
}