//
//  PinkRock.swift
//  DoctorWizard
//
//  Created by drwizzard on 2/13/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import UIKit
import SpriteKit

class PinkRock: SKSpriteNode {
   
    init(rockImageName: String, initialPosition: CGPoint){
        let pinkRockTexture = SKTexture(imageNamed: rockImageName)
        let pinkRockPhysicsBody = SKPhysicsBody(texture: pinkRockTexture, alphaThreshold: 0.1, size: pinkRockTexture.size())
        
        super.init(texture: pinkRockTexture, color: nil, size: pinkRockTexture.size())
        self.physicsBody = pinkRockPhysicsBody
        self.physicsBody?.categoryBitMask = 0x10
        self.physicsBody?.contactTestBitMask = 0x1
        self.position = initialPosition
        self.setScale(0)
        self.alpha = 0
        self.zRotation = CGFloat.random(min: 0, max: 90)
        self.physicsBody?.dynamic = true
        self.physicsBody?.velocity = CGVectorMake(CGFloat.random(min: -100, max: 100) , CGFloat.random(min: -100, max: 100))
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fadeInFadeOut() {
        let duration = NSTimeInterval(CGFloat.random(min: 0, max: 10))
        let grow = SKAction.scaleTo(CGFloat.random(min: 0.5, max: 2.4), duration: duration)
        let fade = SKAction.fadeAlphaTo(0.6, duration: duration/10)
        let wait = SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 4, max: 15)))
        let appear = SKAction.group([grow,fade])
        let reverseGrow = SKAction.scaleTo(0, duration: duration/5)
        let reverseFade = SKAction.fadeAlphaTo(0, duration: duration/5)
        let disopear = SKAction.group([reverseFade, reverseGrow])
        let remove = SKAction.removeFromParent()
        let seq = SKAction.sequence([appear,wait,disopear, remove])
        self.runAction(seq)
    }
    
}
