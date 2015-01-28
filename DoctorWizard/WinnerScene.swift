//
//  WinnerScene.swift
//  DoctorWizard
//
//  Created by drwizzard on 1/28/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import SpriteKit

class WinnerScene: SKScene {
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "youWon")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        addChild(background)
    }
}
