//
//  FireBall.swift
//  DoctorWizard
//
//  Created by Rodrigo Carballo on 2/16/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


class FireBall: SKSpriteNode {
    
    init(fireBallImageName : String, initialPosition: CGPoint) {
        let fireBallTexture = SKTexture(imageNamed: fireBallImageName)
        let fireBallPhysicsBody = SKPhysicsBody(texture: fireBallTexture, alphaThreshold: 0.1, size: fireBallTexture.size())
        super.init(texture: fireBallTexture, color: nil, size: fireBallTexture.size())
        self.position = initialPosition
        self.physicsBody = fireBallPhysicsBody
        self.physicsBody?.categoryBitMask = 0x100
        self.physicsBody?.collisionBitMask = 0x0
        self.physicsBody?.contactTestBitMask = 0x1
        self.physicsBody?.dynamic = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spawnFireBall(layer : BackgroundLayer) {

        self.setScale(2)
        self.zPosition = 0
        let remove = SKAction.removeFromParent()
        let warningApear = SKAction.fadeAlphaTo(1, duration: 0.1)
        let warningDisopear = SKAction.fadeAlphaTo(0, duration: 0.2)
        let displayWarning = SKAction.sequence([SKAction.repeatAction(SKAction.sequence([warningApear,warningDisopear ]), count: 4), remove])
        //warning.runAction(displayWarning)
        
        let moveUp = SKAction.moveToY(self.position.y + 20, duration: 0.9)
        let moveDown = SKAction.moveToY(self.position.y - 20, duration: 0.9)
        var speed :CGFloat = 0.0
        
        let wiggle = SKAction.repeatActionForever(SKAction.sequence([moveDown,moveUp]))
        
        //        let moveAcross = SKAction.moveToX(-1024, duration: NSTimeInterval(CGFloat.random(min: 1, max: 2)))
        var moveTO = layer.convertPoint(CGPoint(
            x: -2048, y: 0), fromNode: self)
        moveTO.y = self.position.y
        let moveAcross = SKAction.sequence([SKAction.moveTo(moveTO, duration: 1.7), remove])
        let move = SKAction.group([wiggle, moveAcross])
        self.runAction(move)
    }
}

