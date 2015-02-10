//
//  Rock.swift
//  DoctorWizard
//
//  Created by drwizzard on 2/9/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import Foundation
import SpriteKit

class Rock {
    var healthPoints = 50
    var sprite : SKSpriteNode
    
    init (rockImageName: String, initialPosition: CGPoint, backgroundLayer:BackgroundLayer, currentScene:SKScene) {
        sprite = SKSpriteNode(imageNamed: rockImageName)
        sprite.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: rockImageName), alphaThreshold: 0.1, size: sprite.size)
        sprite.physicsBody?.collisionBitMask = 0x10
        sprite.position = initialPosition
        let rock = sprite
        rock.setScale(0)
        rock.alpha = 0
        rock.zRotation = CGFloat.random(min: 0, max: 90)
        backgroundLayer.addChild(rock)
        let duration = NSTimeInterval(CGFloat.random(min: 0, max: 10))
        let grow = SKAction.scaleTo(CGFloat.random(min: 0.5, max: 2.4), duration: duration)
        let fade = SKAction.fadeAlphaTo(0.6, duration: duration/10)
        let wait = SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 4, max: 15)))
        let appear = SKAction.group([grow,fade])
        let reverseGrow = SKAction.scaleTo(0, duration: duration/5)
        let reverseFade = SKAction.fadeAlphaTo(0, duration: duration/5)
        let disopear = SKAction.group([reverseFade, reverseGrow])
        let remove = SKAction.removeFromParent()
//        let curentLevel = currentLevelIs()
//        if curentLevel == .First || curentLevel == .Second {
            let seq = SKAction.sequence([appear,wait,disopear, remove])
            rock.runAction(seq)
//        } else {
//            let positionToDouble = randomSpawnPoint()
//            let moveToPositon = positionToDouble * 2
//            let convertedPositon = self.backgroundLayer.convertPoint(positionToDouble, fromNode: self)
//            let move = SKAction.moveTo(convertedPositon, duration: NSTimeInterval(CGFloat.random(min: 8, max: 12)))
//            let moveApear = SKAction.group([grow,move,fade])
//            rock.runAction(SKAction.sequence([moveApear, disopear, remove]))
//        }

    }
    
}