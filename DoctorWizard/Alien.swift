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
    
    init(alienImageName : String, initialPosition: CGPoint) {
        let alienTexture = SKTexture(imageNamed: alienImageName)
        super.init(texture: alienTexture, color: nil, size: alienTexture.size())
        self.position = initialPosition
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spawnAlien(dudePosition : CGPoint) {
        self.zRotation = CGFloat.random(min:0, max: 90)
        var directions : [SKAction] = []
        var points : [CGPoint] = []
        points.append(dudePosition)
        
        for i in 1...25 {
            let randx = CGFloat.random(min: -250, max: 250)
            let randy = CGFloat.random(min: -250, max: 250)
            let point = CGPoint(x: points[i-1].x + randx, y: points[i-1].y + randy)
            
            let action = SKAction.moveTo(point, duration: NSTimeInterval(0.1))
            points.append(point)
            directions.append(action)
        }
        
        let remove = SKAction.removeFromParent()
        directions.append(remove)
        
        let move = SKAction.moveTo(dudePosition, duration: 3)
        let wait = SKAction.waitForDuration(1)
        self.runAction(SKAction.sequence([move,wait, SKAction.sequence(directions)]))

        
    }
}
