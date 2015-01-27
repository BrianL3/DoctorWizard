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
    var backgroundImageName = "background_test"
    var starsImageName = "stars_test"
    
    
    
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
        
        
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnRock),
                SKAction.waitForDuration(1.0)])))
    
        //simulate SKSpriteNode for collision purposes
        dude.zPosition = 0
        
        
        //add background layers to to mainview
        addMovingBackground()
    }
    
    //called before each frame is rendered
    override func update(currentTime: NSTimeInterval) {
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        
        lastUpdateTime = currentTime
       // println("\(dt*1000) milliseconds since last update")
        
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
        moveBackground()
        moveStars()
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
        //println("Amount to move: \(amountToMove)")
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
        
        // set the background verticle scrolling direction
        let previousY = touch.previousLocationInView(self.view).y
        let currentY = touch.locationInView(self.view).y
        self.backgroundVerticalDirection = currentY - previousY
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
        for i in 0...1 {
            let bottomBackground = backgroundNode()
            bottomBackground.position = CGPoint(
                x: CGFloat(i) * bottomBackground.size.width,
                y: 0)
            bottomBackground.name = "background"
            let topBackground = backgroundNode()
            topBackground.position = CGPoint(
                x: CGFloat(i) * bottomBackground.size.width,
                y: bottomBackground.size.height)
            topBackground.name = "background"
            backgroundLayer.addChild(bottomBackground)
            backgroundLayer.addChild(topBackground)
            
            
            
            let bottomStar = starsNode()
            bottomStar.position = CGPoint(
                x: CGFloat(i) * bottomBackground.size.width,
                y: 0)
            bottomStar.name = "stars"
            let topStar = starsNode()
            topStar.position = CGPoint(
                x: CGFloat(i) * bottomBackground.size.width,
                y: bottomBackground.size.height)
            topStar.name = "stars"
            
            starLayer.addChild(bottomStar)
            starLayer.addChild(topStar)
            
        }
    }
    
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPointZero
        
        var background1 = SKSpriteNode(imageNamed: self.backgroundImageName)
        background1.anchorPoint = CGPointZero
        background1.position = CGPointZero
        backgroundNode.addChild(background1)
        
        var background2 = SKSpriteNode(imageNamed: self.backgroundImageName)
        background2.anchorPoint = CGPointZero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        var background3 = SKSpriteNode(imageNamed: self.backgroundImageName)
        background3.anchorPoint = CGPointZero
        background3.position = CGPoint(x: 0, y: background3.size.height)
        backgroundNode.addChild(background3)
        
        var background4 = SKSpriteNode(imageNamed: self.backgroundImageName)
        background4.anchorPoint = CGPointZero
        background4.position = CGPoint(x: background4.size.width, y: background4.size.height)
        backgroundNode.addChild(background4)
        
        backgroundNode.size = CGSize(
            width: background1.size.width * 2,
            height: background1.size.height * 2)
        return backgroundNode
    }
    
    func starsNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPointZero

        
        
        var stars1 = SKSpriteNode(imageNamed: self.starsImageName)
        stars1.anchorPoint = CGPointZero
        stars1.position = CGPointZero
        backgroundNode.addChild(stars1)
        
        var stars2 = SKSpriteNode(imageNamed: self.starsImageName)
        stars2.anchorPoint = CGPointZero
        stars2.position = CGPoint(x: stars1.size.width, y: 0)
        backgroundNode.addChild(stars2)
        
        var stars3 = SKSpriteNode(imageNamed: self.starsImageName)
        stars3.anchorPoint = CGPointZero
        stars3.position = CGPoint(x: 0, y: stars1.size.height)
        backgroundNode.addChild(stars3)
        
        var stars4 = SKSpriteNode(imageNamed: self.starsImageName)
        stars4.anchorPoint = CGPointZero
        stars4.position = CGPoint(x: stars1.size.width, y: stars1.size.height)
        backgroundNode.addChild(stars4)
        
        backgroundNode.size = CGSize(
            width: stars4.size.width * 2,
            height: stars4.size.height * 2)
        return backgroundNode
    }
    
    func moveBackground(){
        let backgroundVelocity = CGPoint(
            x: -self.backgroundLayerMovePointsPerSec,
            y: self.backgroundVerticalDirection *  60)
        let ammountToMove = backgroundVelocity * CGFloat(dt)
        self.backgroundLayer.position += ammountToMove
        
        backgroundLayer.enumerateChildNodesWithName("background", usingBlock: { (node, _) -> Void in
            let background = node as SKSpriteNode
            let backgroundScreenPos = self.backgroundLayer.convertPoint(background.position, toNode: self)
            if backgroundScreenPos.x <= -background.size.width {
                background.position.x = background.position.x + background.size.width*2
            }
            if backgroundScreenPos.y <= -background.size.height {
                background.position.y = background.position.y + background.size.height*2
            }
            if backgroundScreenPos.y >= background.size.height {
                background.position.y = background.position.y - background.size.height*2
            }
        })
    }
    
    func moveStars(){
        let backgroundVelocity = CGPoint(
            x: -self.backgroundLayerMovePointsPerSec,
            y: self.backgroundVerticalDirection *  100)
        let ammountToMove = backgroundVelocity * CGFloat(dt)
        self.starLayer.position += ammountToMove
        
        starLayer.enumerateChildNodesWithName("stars", usingBlock: { (node, _) -> Void in
            let background = node as SKSpriteNode
            let backgroundScreenPos = self.starLayer.convertPoint(background.position, toNode: self)
            if backgroundScreenPos.x <= -background.size.width {
                background.position.x = background.position.x + background.size.width*2
            }
            if backgroundScreenPos.y <= -background.size.height {
                background.position.y = background.position.y + background.size.height*2
            }
            if backgroundScreenPos.y >= background.size.height {
                background.position.y = background.position.y - background.size.height*2
            }
        })
    }
        
    
        
    
}
