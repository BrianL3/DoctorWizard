//
//  BlackHole.swift
//  DoctorWizard
//
//  Created by Rodrigo Carballo on 2/15/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class BlackHole: SKSpriteNode {
    
    init(blacHoleImageName : String, initialPosition: CGPoint) {
        let blackHoleTexture = SKTexture(imageNamed: blacHoleImageName)
        super.init(texture: blackHoleTexture, color: nil, size: blackHoleTexture.size())
        self.position = initialPosition
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spawnBlackHole() {
        let angle : CGFloat = -CGFloat(M_PI)
        let oneSpin = SKAction.rotateByAngle(angle, duration: 15)
        let repeatSpin = SKAction.repeatActionForever(oneSpin)
        let appear = SKAction.scaleTo(9, duration: 3.0)
        let implode = SKAction.scaleTo(0, duration: 3.0)
        let actionRemove = SKAction.removeFromParent()
        let seq = SKAction.sequence([oneSpin,repeatSpin, appear, implode, actionRemove])
        self.runAction(seq)
    }
}