//
//  Alien.swift
//  DoctorWizard
//
//  Created by Rodrigo Carballo on 2/16/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


class Alien: SKSpriteNode {
    let initialPosition:CGPoint
    
    init(alienImageName : String, initialPosition: CGPoint) {
        let alienTexture = SKTexture(imageNamed: alienImageName)
        self.initialPosition = initialPosition
        let alienBody = SKPhysicsBody(texture: alienTexture, alphaThreshold: 0.1, size: alienTexture.size())
        super.init(texture: alienTexture, color: nil, size: alienTexture.size())
        self.physicsBody = alienBody
        self.physicsBody?.categoryBitMask =  0x1000
        self.physicsBody?.collisionBitMask = 0x0
        self.physicsBody?.contactTestBitMask = 0x1
        
        self.position = initialPosition
        self.setScale(0)
        self.alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spawnAlien(destinationPoint:CGPoint) {
        self.zRotation = CGFloat.random(min:0, max: 90)
        let remove = SKAction.removeFromParent()
        self.zPosition = 2
        let scaleIn = SKAction.scaleTo(1, duration: 0.3)
        let scaleOut = SKAction.scaleTo(0, duration: 0.3)
        let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.3)
        let fadeOut = SKAction.fadeAlphaTo(0, duration: 0.3)
        let appear = SKAction.group([fadeIn,scaleIn])
        let disappear = SKAction.group([fadeOut,scaleOut])
        let move = SKAction.moveTo(destinationPoint, duration: 3)
        let wait = SKAction.waitForDuration(1)
        self.runAction(SKAction.sequence([appear, move, disappear, remove]))
    }
}
