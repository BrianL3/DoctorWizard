//
//  Dragon.swift
//  DoctorWizard
//
//  Created by Rodrigo Carballo on 2/15/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class Dragon: SKSpriteNode {
    
    var sequenceDragonActions : [SKAction] = []

    init(dragonImageName : String, initialPosition: CGPoint) {
        let dragonTexture = SKTexture(imageNamed: dragonImageName)
        super.init(texture: dragonTexture, color: nil, size: dragonTexture.size())
        self.position = initialPosition
        println("Original position of Dragon")
        println(self.position)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spawnDragon(layer : BackgroundLayer) {
        self.setScale(0)
        self.zPosition = 9
        let appear = SKAction.scaleTo(0.6, duration: 1)
        self.runAction(appear)

        for index in 1...60 {
            let posX : CGFloat = CGFloat.random(min: 0, max: 4096) - 1024
            let posY : CGFloat = CGFloat.random(min: 0, max: 3072) - 767
            let positionToConvert = CGPoint(x: posX, y: posY)
            let positionToMove = layer.convertPoint(positionToConvert, fromNode: layer)
            println("Destination position for Dragon")
            println(positionToMove)

            let actionMove = SKAction.moveTo(positionToMove, duration: 1)
            sequenceDragonActions.append(actionMove)
            }
        let actionDragonAttack = SKAction.sequence(sequenceDragonActions)

        let actionRemove = SKAction.removeFromParent()
        let dragonKillEverything = [actionDragonAttack, actionRemove]
        self.runAction(SKAction.sequence(dragonKillEverything))
        }
    }
    

