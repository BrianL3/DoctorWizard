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
    var blackHoleAnimation: SKAction
    
    init(blacHoleImageName : String, initialPosition: CGPoint) {
        var animationTextues:[SKTexture] = []
        for i in 0...10 {
            animationTextues.append(SKTexture(imageNamed: "blackWhole-animation_\(i)"))
        }
       self.blackHoleAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(animationTextues, timePerFrame: 0.05))
        
        let blackHoleText  = SKTexture(imageNamed: "blackWhole-animation_1")
        let blackHoleBody = SKPhysicsBody(texture: blackHoleText, alphaThreshold: 0.1, size: blackHoleText.size())
        super.init(texture: blackHoleText, color: nil, size: blackHoleText.size())
        self.runAction(SKAction.repeatActionForever(self.blackHoleAnimation))
        self.physicsBody = blackHoleBody

        self.physicsBody?.categoryBitMask = 0x10000
        self.physicsBody?.contactTestBitMask = 0x1
        self.physicsBody?.collisionBitMask = 0x0
        self.name = "blackhole"
        self.position = initialPosition
        self.zPosition = 0
        self.setScale(0)

        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spawnBlackHole() {
        let angle : CGFloat = -CGFloat(M_PI)
        let oneSpin = SKAction.rotateByAngle(angle, duration: 5)
//        let repeatSpin = SKAction.repeatActionForever(oneSpin)
        let repeatSpin = SKAction.repeatAction(oneSpin, count: 5)
        let appear = SKAction.scaleTo(2.5, duration: 3.0)
        let appearAndSpin = SKAction.group([appear,repeatSpin])
        let implode = SKAction.scaleTo(0, duration: 3.0)
        let implodeAndSpin = SKAction.group([implode,repeatSpin])
        let actionRemove = SKAction.removeFromParent()
        
//        let seq = SKAction.sequence([oneSpin,repeatSpin, appear, implode, actionRemove])
        let seq = SKAction.sequence([appearAndSpin, implode, actionRemove])
        self.runAction(seq)
    }
}