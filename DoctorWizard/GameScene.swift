//
//  GameScene.swift
//  DoctorWizard
//
//  Created by nacnud on 1/26/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let dude: SKSpriteNode = SKSpriteNode(imageNamed: "dude")
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let dudeMovePointsPerSec: CGFloat = 1000.0
    var velocity = CGPointZero
    var lastTouchLocation: CGPoint?

    
    override func didMoveToView(view: SKView) {
        
        dude.position = CGPoint(x: 400, y: 400)
        dude.setScale(0.75)
        addChild(dude)
      
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        println("\(dt*1000) milliseconds since last update")
        
        if let lastTouch = lastTouchLocation {
            let diff = lastTouch - dude.position
            if (diff.length() <= dudeMovePointsPerSec * CGFloat(dt)) {
                dude.position = lastTouchLocation!
                velocity = CGPointZero
            } else {
                moveSprite(dude, velocity: velocity)
            }
        }

        
        
        
        
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity.y * CGFloat(dt)
        println("Amount to move: \(amountToMove)")
        sprite.position += CGPoint(x: 0, y: amountToMove)
    }
    
    func moveDudeToward(location: CGPoint) {
        let offset = location - dude.position
        let direction = offset.normalized()
        velocity = direction * dudeMovePointsPerSec
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveDudeToward(touchLocation)
    }
    
    override func touchesBegan(touches: NSSet,
        withEvent event: UIEvent) {
            let touch = touches.anyObject() as UITouch
            let touchLocation = touch.locationInNode(self)
            sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: NSSet,
        withEvent event: UIEvent) {
            let touch = touches.anyObject() as UITouch
            let touchLocation = touch.locationInNode(self)
            sceneTouched(touchLocation)
    }

}
