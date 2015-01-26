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
    //let rock : SKSpriteNode =  SKSpriteNode(imageNamed: "Rock")
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let dudeMovePointsPerSec: CGFloat = 1000.0
    var velocity = CGPointZero
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    
    
    //MARK: INTIALIZER ===============================================================================
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin,
            width: size.width,
            height: playableHeight) // 4
        super.init(size: size) // 5
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    
    
    //MARK: DID MOVE TO VIEW ======================================================================
    
    override func didMoveToView(view: SKView) {
        
        dude.position = CGPoint(x: 400, y: 400)
        dude.setScale(0.75)
        addChild(dude)
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnRock),
                SKAction.waitForDuration(1.0)])))
        
    
    }
    
    //called before each frame is rendered
    override func update(currentTime: CFTimeInterval) {
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        
        lastUpdateTime = currentTime
        //println("\(dt*1000) milliseconds since last update")
        
        if let lastTouch = lastTouchLocation {
            
            let diff = lastTouch - dude.position
         
            if (diff.length() <= dudeMovePointsPerSec * CGFloat(dt)) {
                dude.position = lastTouchLocation!
                velocity = CGPointZero
            } else {
                moveSprite(dude, velocity: velocity)
            }
        }
        
        boundsCheckDude()
    }
    
    
    //MARK: MOVE THE DUDE ======================================================================

    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        
        let amountToMove = velocity.y * CGFloat(dt)
        
        //println("Amount to move: \(amountToMove)")
        
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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    
    //MARK: CHECK BOUNDS ========================================================================
    
    func boundsCheckDude() {
        
        let bottomLeft  = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight    = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        if dude.position.y <= bottomLeft.y {
            dude.position.y = bottomLeft.y
            velocity.y = 0
        }
        if dude.position.y >= topRight.y {
            dude.position.y = topRight.y
            velocity.y = 0
        } 
    }
    
    //MARK: SPAWN ROCKS ========================================================================
    
    func spawnRock() {
        let rock = SKSpriteNode(imageNamed: "Rock")
        rock.name = "rock"
        rock.position = CGPoint(
            x: CGFloat.random(min: CGRectGetMinX(playableRect),
                max: CGRectGetMaxX(playableRect)),
            y: size.height)
        rock.setScale(0)
        addChild(rock)
        let appear = SKAction.scaleTo(1, duration: 2.0)
        let actions = [appear]
        rock.runAction(SKAction.sequence(actions))
        let actionMove =
        SKAction.moveToY(-rock.size.height/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        rock.runAction(SKAction.sequence([actionMove, actionRemove]))
     
        
    }
  
//
//    func checkCollisions() {
//        
//        var hitBounds: [] = []
//    }


}
