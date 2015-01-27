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
    let dudeMovePointsPerSec: CGFloat = 2000.0
    var velocity = CGPointZero
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var invincible = false
    var backgroundLayer = SKNode()
    var starLayer = SKNode()
    var backgroundLayerMovePointsPerSec: CGFloat = 300
    var backgroundVerticalDirection: CGFloat = 1.0
    
    
    //MARK: INTIALIZER ==============================================================================
    
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
        
        dude.position = CGPoint(x: 700, y: 400)
        dude.setScale(0.75)
        addChild(dude)
        
        //setup movingbackground
        
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnRock),
                SKAction.waitForDuration(1.0)])))
    
        //simulate SKSpriteNode for collision purposes
        dude.zPosition = 0
    }
    
    //called before each frame is rendered
    override func update(currentTime: NSTimeInterval) {
        
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
        
        boundsCheckDude()
    }
    
    override func didEvaluateActions() {
        
        checkCollisions()
    }
    
    //MARK: MOVE THE DUDE ======================================================================

    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        
//        let amountToMove = velocity.y * CGFloat(dt)
//        
//        //println("Amount to move: \(amountToMove)")
//        
//        sprite.position += CGPoint(x: 0, y: amountToMove)
        
        // 1
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
            y: velocity.y * CGFloat(dt))
        println("Amount to move: \(amountToMove)")
        // 2
        sprite.position = CGPoint(
            x: sprite.position.x + amountToMove.x,
            y: sprite.position.y + amountToMove.y)
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
            velocity.y = -velocity.y
        }
        if dude.position.y >= topRight.y {
            dude.position.y = topRight.y
            velocity.y = -velocity.y
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
        rock.setScale(1)
        rock.zPosition = 0
        addChild(rock)
        let appear = SKAction.scaleTo(3, duration: 4.0)
        let actions = [appear]
        rock.runAction(SKAction.sequence(actions))
        let actionMove =
        SKAction.moveToY(-rock.size.height/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        rock.runAction(SKAction.sequence([actionMove, actionRemove]))}
    
  
    //MARK: COLLISIONS ==========================================================================
    
    func dudeHitRock(enemy: SKSpriteNode) {
        //here dude beceomes invincible and blinks when hit by a rock
        invincible = true
        
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customActionWithDuration(duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime) % slice
            node.hidden = remainder > slice / 2
        }
        let setHidden = SKAction.runBlock() {
            self.dude.hidden = false
            self.invincible = false
        }
        dude.runAction(SKAction.sequence([blinkAction, setHidden]))
    }
    
    func checkCollisions() {
        
        var hitObstacle: [SKSpriteNode] = []
        
        enumerateChildNodesWithName("rock") { node, _ in
            
            let rockHit = node as SKSpriteNode
            
            if CGRectIntersectsRect(rockHit.frame, self.dude.frame) {
                hitObstacle.append(rockHit)
                self.velocity = CGPoint(x:0, y:0)
            }
        }
        //sets up dude for stunning and becoming invincible
        for rock in hitObstacle {
            dudeHitRock(rock)
        }

    }
    
    func addMovingBackground(){
        self.backgroundLayer.zPosition = -2
        self.starLayer.zPosition = -1
        self.addChild(backgroundLayer)
        self.addChild(starLayer)
        
    }
}
