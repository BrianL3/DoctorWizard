//
//  Player.swift
//  DoctorWizard
//
//  Created by drwizzard on 2/13/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import UIKit
import SpriteKit

class Player: SKSpriteNode {
    var healthPoints: Int = 500
    let maximumHealthPoints : Int = 500
    var direction:String = "right"
    let dudeAnimationRight:SKAction
    let dudeAnimationLeft:SKAction
    var isInvincible:Bool = false
    var hitByBlackHole = false
    var velocity = CGPointZero
    
    override init(){
        var texturesRight: [SKTexture] = []
        var texturesLeft: [SKTexture] = []
        for i in 0...10 {
            texturesRight.append(SKTexture(imageNamed: "dude\(i)" ))
            texturesLeft.append(SKTexture(imageNamed: "dudeLeft\(i)"))
        }
        self.dudeAnimationRight = SKAction.repeatActionForever(SKAction.animateWithTextures(texturesRight, timePerFrame: 0.1))
        self.dudeAnimationLeft = SKAction.repeatActionForever(SKAction.animateWithTextures(texturesLeft, timePerFrame: 0.1))
        
        let playerTexture = SKTexture(imageNamed: "dude0")

        super.init(texture: playerTexture, color: nil, size: playerTexture.size())
        self.setScale(0.75)
        
        self.physicsBody = SKPhysicsBody(texture: texturesLeft[0], alphaThreshold: 0.1, size: self.size)
        self.physicsBody?.categoryBitMask = 0x1
        self.physicsBody?.dynamic = false
        self.physicsBody?.collisionBitMask = 0
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateDude(backgroundDirection:CGPoint){
        if backgroundDirection.x >= CGFloat(0.0) && self.direction != "left" {
            self.removeAllActions()
            self.runAction(SKAction.repeatActionForever(dudeAnimationLeft))
            self.direction = "left"
        } else if backgroundDirection.x < CGFloat(0.0) && self.direction != "right" {
            self.removeAllActions()
            self.runAction(SKAction.repeatActionForever(dudeAnimationRight))
            self.direction = "right"
        }
        
    }
    
    //MARK: COLORIZE
    func flashDude() -> SKAction{
        
        let changeColorToRedAction = SKAction.colorizeWithColor(SKColorWithRGB(255, 64, 64), colorBlendFactor: 1.0, duration: 0.1)
        let changeColorToWhiteAction = SKAction.colorizeWithColor(SKColorWithRGB(255, 255, 255), colorBlendFactor: 1.0, duration: 0.1)
        let changeColorToYellowAction = SKAction.colorizeWithColor(SKColorWithRGB(255, 255, 0), colorBlendFactor: 1.0, duration: 0.1)
        let waitAction = SKAction.waitForDuration(0.2)

        let healthPercentage : Float = Float(self.healthPoints)/Float(self.maximumHealthPoints)
//        println(self.healthPoints)
//        println(self.maximumHealthPoints)
//        println("health percentage is at: \(healthPercentage)")
        switch healthPercentage{
        case 0..<0.25 :
            let hitAction = SKAction.sequence([changeColorToRedAction, waitAction, changeColorToWhiteAction, waitAction, changeColorToRedAction, waitAction, changeColorToWhiteAction, waitAction, changeColorToRedAction, waitAction, changeColorToWhiteAction])
            return hitAction
        case 0.25..<0.5:
            let hitAction = SKAction.sequence([changeColorToRedAction, waitAction, changeColorToWhiteAction, waitAction, changeColorToYellowAction, waitAction, changeColorToWhiteAction, waitAction, changeColorToRedAction, waitAction, changeColorToWhiteAction])
            return hitAction
        default :
            let hitAction = SKAction.sequence([changeColorToYellowAction, waitAction, changeColorToWhiteAction, waitAction, changeColorToYellowAction, waitAction, changeColorToWhiteAction, waitAction, changeColorToYellowAction, waitAction, changeColorToWhiteAction])
            return hitAction

        }
    }
    
    func setInvincible(){
        self.isInvincible = true
//        println("is now set invicble")
//        let wait = SKAction.waitForDuration(0.7)
//
//        let disable = SKAction.runBlock { () -> Void in
//            self.isInvincible = false
//            println("self.dude is should not be invincible now")
//        }
//        
//        let seq = SKAction.sequence([wait,disable])
//        self.runAction(seq)
    }
    
    
}
