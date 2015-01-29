//
//  GameScene.swift
//  DoctorWizard
//
//  Created by nacnud on 1/26/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import SpriteKit

protocol MainMenuDelegate {
    func playerDidLose()
    func restartWithSameSong(usingDefaultSong: Bool)
    func restartWithDifferentSong()
}

class GameScene: SKScene {
    
    let dude: SKSpriteNode = SKSpriteNode(imageNamed: "dude0")
    let blackHole: SKSpriteNode = SKSpriteNode(imageNamed: "blackhole2")
    let dragon : SKSpriteNode = SKSpriteNode(imageNamed: "dragon2")
    let dudeAnimation : SKAction
    
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
    // song-related variables
    var songDuration : NSTimeInterval!
    var songGenre : String!
    var backgroundLayerMovePointsPerSec: CGFloat = 300
    var backgroundVerticalDirection: CGFloat = 6.0
    var gameStartTime : NSTimeInterval = 0
    var timePassed : NSTimeInterval = 0
    var backgroundImageName = "background0"
    var starsImageName = "starsFinal"
    
    var altitude: CGFloat = 0
    var curLevel : Level = .First
    
    var healthPoints :CGFloat = 742

    var didLose = false
    var menuDelegate: MainMenuDelegate?
    
    //booleans to determine if enemies are on the field of play
    var rocksOn : Bool = false
    var fireBallOn : Bool = false
    var alienOn : Bool = false
    var blackHoleOn : Bool = false
    var dragonOn : Bool = false
    
    //MARK: INTIALIZER ==============================================================================
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin,
            width: size.width,
            height: playableHeight) // 4
        
        
        // setup dude_animation
        var textures: [SKTexture] = []
        for i in 0...10 {
            textures.append(SKTexture(imageNamed: "dude\(i)"))
        }
        
        self.dudeAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.1))
        
        super.init(size: size)
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    

    //MARK: DID MOVE TO VIEW ======================================================================
    
    override func didMoveToView(view: SKView) {
        
        dude.position = CGPoint(x: 700, y: 400)
        dude.setScale(0.75)
        dude.runAction(SKAction.repeatActionForever(dudeAnimation))
        dude.name = "dude"
        addChild(dude)
        
        //simulate SKSpriteNode for collision purposes
        dude.zPosition = 0
        
        //add background layers to to mainview
        addMovingBackground(self.backgroundImageName)
        self.addChild(backgroundLayer)
        self.addChild(starLayer)
       
        
    }
    
    //called before each frame is rendered
    override func update(currentTime: NSTimeInterval) {
        if gameStartTime == 0 {
            gameStartTime = currentTime
        }
        
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
        
        self.timePassed = round((currentTime - gameStartTime) * 10 )/10
        
        
        if timePassed % 0.5 == 0 {
            if self.backgroundVerticalDirection < 0 {
                self.altitude += 1
            } else if self.backgroundVerticalDirection > 0 {
                self.altitude -= 1
            }
        }
        
        
        //Sections that determines which enemmies come to playing field based on Level of tune
        
        switch currentLevelIs()
        {
            
        case .First:
//            if !dragonOn {
//                actionToSpawnDragon()
//                println("First scene on now")
//            }
            
            if !rocksOn {
                actionToSpawnRocks()
                println("First scene on now")
            }
            
        case .Second:
            if !fireBallOn {
                if self.backgroundImageName == "background0" {
                    println("switch to background 2")
                    
                    self.backgroundImageName = "background1"
                    addMovingBackground(self.backgroundImageName)
                }
                
                actionToSpawnFireBalls()
                println("Second scene on now")
            }

        case .Third:
            if !alienOn {
                if self.backgroundImageName == "background1" {
                    self.backgroundImageName = "background2"
                    addMovingBackground(self.backgroundImageName)
                }
                
                actionToSpawnAlien()
                println("Third scene on now")
            }
            
        case .Fourth:
            if !blackHoleOn {
                if self.backgroundImageName == "background2" {
                    self.backgroundImageName = "background3"
                    addMovingBackground(self.backgroundImageName)
                }
                
                actionToSpawnBlackHole()
                println("Fourth scene on now")
            }
        case .Fifth:
            if self.backgroundImageName == "background3" {
                self.backgroundImageName = "background4"
                addMovingBackground(self.backgroundImageName)
            }
            if !dragonOn{
                actionToSpawnDragon()
                println("Fifth scene on now")
            }
            
            println("Fifth scene on now")
            
            
        default:
            if self.backgroundImageName == "background4" {
                self.backgroundImageName = "background0"
                addMovingBackground(self.backgroundImageName)
            }
            
            println("DefaultLevel")
        }
        
        if self.healthPoints <= 0 {
            self.healthPoints = 0
            self.didLose = true
        }
        
        //println(self.altitude)
        boundsCheckDude()
        moveBackground()
        moveStars()
    }
    
    override func didEvaluateActions() {
        if self.didLose == true{
            self.scene?.paused = true
            let lostGameScene = LooserScene(size: self.size)
            lostGameScene.mainMenuDelegate = self.menuDelegate
            if self.songGenre == "DefaultDuncanSong"{
                lostGameScene.isDefaultSong = true
            }
            
            self.view?.presentScene(lostGameScene)

        }
        checkCollisions()
        destroyedByBlackHole()
    }
    
    //MARK: MOVE THE DUDE ======================================================================
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        
        
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
            y: velocity.y * CGFloat(dt))
//        println("Amount to move: \(amountToMove)")
        
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
//        println("song duration is : \(songDuration)")
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
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
    
    //MARK: SPAWN FIREBALLS ====================================================================

    func spawnFireball() {
        let fireBall = SKSpriteNode(imageNamed: "fireball")
        let oldPosition = fireBall.position
        let upPosition = oldPosition + CGPoint(x: 0, y: 80)
        let upEffect = SKTMoveEffect(node: fireBall, duration: 0.9, startPosition: oldPosition, endPosition: upPosition)
        upEffect.timingFunction = { t in pow(1, -1 * t) * (sin(t * π * 3))}
        let upAction = SKAction.actionWithEffect(upEffect)
        let upActionRepeat = SKAction.repeatActionForever(upAction)
        fireBall.name = "fireball"
        fireBall.position = CGPoint(x: size.width - fireBall.size.width/2, y: CGFloat.random(min: CGRectGetMinY(playableRect), max: CGRectGetMaxY(playableRect)))
        fireBall.setScale(1)
        fireBall.zPosition = 0
        addChild(fireBall)
        let appear = SKAction.scaleTo(3, duration: 4.0)
        let actions = [appear]
        fireBall.runAction(SKAction.sequence(actions))
        let actionMove =
        SKAction.moveToX(-fireBall.size.height/2, duration: 1.0)
        let actionRemove = SKAction.removeFromParent()
        fireBall.runAction(SKAction.sequence([SKAction.group([upAction, actionMove]),actionRemove]))
    }

    //MARK: SPAWN ALIENS ======================================================================
    
    func spawnAlien() {
        let alien = SKSpriteNode(imageNamed: "alienspaceship")
        alien.name = "alienspaceship"
        alien.position = CGPoint(
            x: CGFloat.random(min: CGRectGetMinX(playableRect) + alien.frame.size.width,
                max: CGRectGetMaxX(playableRect)),
            y: size.height)
        alien.setScale(1)
        alien.zPosition = 0
        addChild(alien)
        var randomXPosition = CGFloat.random(min: 0, max: size.width)
        var randomYPosition = CGFloat.random(min: 0, max: size.height)
        let appear = SKAction.scaleTo(1, duration: 2.0)
        let actions = [appear]
        alien.runAction(SKAction.sequence(actions))
        let actionMoveYDown =
        SKAction.moveToY(0, duration: 2.0)
        let actionMoveX =
        SKAction.moveToX(randomXPosition, duration: 0.5)
        let actionMoveYUp =
        SKAction.moveToY(size.height - alien.frame.height / 2, duration: 4.0)

        let actionRemove = SKAction.removeFromParent()
        alien.runAction(SKAction.sequence([actionMoveYDown, actionMoveX, actionMoveYUp, actionRemove]))}
    
    
    //MARK: BLACK HOLE =========================================================================
    
    func spawnBlackHole() {
        //blackHole = SKSpriteNode(imageNamed: "blackhole")
        blackHole.name = "blackhole"
        //logic to detect where blackhole should land based on it massive size and powerful feature
        blackHole.position = CGPoint(
            x: CGFloat.random(min: CGRectGetMinX(playableRect) + blackHole.frame.width,
                max: CGRectGetMaxX(playableRect) - blackHole.frame.width),
            y: CGFloat.random(min: CGRectGetMinX(playableRect) + blackHole.frame.height,
                max: (CGRectGetMaxX(playableRect) - (5 * blackHole.frame.height))))
        blackHole.setScale(0)
        blackHole.zPosition = -1
        addChild(blackHole)
        let angle : CGFloat = -CGFloat(M_PI)
        let oneSpin = SKAction.rotateByAngle(angle, duration: 5)
        let repeatSpin = SKAction.repeatActionForever(oneSpin)
        let appear = SKAction.scaleTo(4, duration: 15.0)
        let inplode = SKAction.scaleTo(0, duration: 15.0)
        let actionRemove = SKAction.removeFromParent()
        let actions = [appear, inplode, actionRemove]
        blackHole.runAction(repeatSpin)
        blackHole.runAction((SKAction.sequence(actions)))}
    
    //MARK: DRAGON ==============================================================================
    
    func spawnDragon() {
        
        //this controls whether we go on X, Y or Circle
        var randomWhereDragonGoes = Int.random(1...9)
        
        //random variable for dragon movement
        var randomXChooser = CGFloat(Int.random(0...Int(playableRect.width)))
        var randomYChooser = CGFloat(Int.random(0...Int(playableRect.height)))
        
        switch randomWhereDragonGoes {
            
        case 1...3:
            SKAction.moveToX(randomYChooser -  dragon.frame.width / 2, duration: 1.0)
            println("Im on 1 to 3 - Dragon Move")
            
        case 4...6:
            
            SKAction.moveToY(randomYChooser -  dragon.frame.height / 2, duration: 1.0)
            println("Im on 4 to 6 - Dragon Move")

            
        case 7...9:
            println("Im on 7 to 9 - Dragon Move")
            
        default:
            println("DefaultLevel")

            
        }
        
        
        //let actionMoveY
        
        
        dragon.name = "dragon"
        println("I made it to spawnDragon")
        dragon.position = CGPoint(
            x: CGFloat.random(min: CGRectGetMinX(playableRect) + dragon.frame.width,
                max: CGRectGetMaxX(playableRect) - dragon.frame.width),
            y: CGFloat.random(min: CGRectGetMinX(playableRect) + dragon.frame.height,
                max: (CGRectGetMaxX(playableRect) - (5 * dragon.frame.height))))
        println(dragon.position)
        dragon.setScale(0)
        dragon.zPosition = -1
        addChild(dragon)
        let appear = SKAction.scaleTo(1.3, duration: 5.0)
        //following actions determine random movement
        
        let actionMoveYDown =
        SKAction.moveToY(0, duration: 2.0)
//        let actionMoveX =
//        SKAction.moveToX(randomXPosition, duration: 0.5)
//        let actionMoveYUp =
//        SKAction.moveToY(size.height - dragon.frame.height / 2, duration: 4.0)
//        
//        let actionRemove = SKAction.removeFromParent()

    }
    
    
    //MARK: COLLISIONS ==========================================================================
    
    func dudeHitObject(enemy: SKSpriteNode) {
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
                if self.invincible == false {
                    self.healthPoints -= CGFloat.random(min: 50, max: 100)
                }
            }
        }
        
        enumerateChildNodesWithName("fireball") { node, _ in
            
            let fireballHit = node as SKSpriteNode
            
            if CGRectIntersectsRect(fireballHit.frame, self.dude.frame) {
                hitObstacle.append(fireballHit)
                self.velocity = CGPoint(x:0, y:0)
                if self.invincible == false {
                    self.healthPoints -= CGFloat.random(min: 80, max: 140)
                }
            }
        }
        //sets up dude for stunning and becoming invincible
        for incomingObject in hitObstacle {
            dudeHitObject(incomingObject)
        }
        
    }
    
    func destroyedByBlackHole() {
        
        enumerateChildNodesWithName("rock") { node, _ in
            
            let rockHit = node as SKSpriteNode
            
            if CGRectIntersectsRect(rockHit.frame, self.blackHole.frame) {
                rockHit.removeFromParent()
                
            }
            
        }
        
        enumerateChildNodesWithName("fireball") { node, _ in
            
            let fireballHit = node as SKSpriteNode
            
            if CGRectIntersectsRect(fireballHit.frame, self.blackHole.frame) {
                fireballHit.removeFromParent()
                
            }
        }
        
        enumerateChildNodesWithName("dude") { node, _ in
            
            let dudeHit = node as SKSpriteNode
            
            if CGRectIntersectsRect(dudeHit.frame, self.blackHole.frame) {
                dudeHit.removeFromParent()
                if self.invincible == false {
                    self.healthPoints = 0
                }
            }
        }
        
        enumerateChildNodesWithName("alienspaceship") { node, _ in
            
            let alienHit = node as SKSpriteNode
            
            if CGRectIntersectsRect(alienHit.frame, self.blackHole.frame) {
                alienHit.removeFromParent()
                
            }
        }
    }
    
    func addMovingBackground(backgroundName:String ){
        self.backgroundLayer.removeAllChildren()
        self.backgroundLayer.zPosition = -2
        self.starLayer.zPosition = -1
        for i in 0...1 {
            let bottomBackground = backgroundNode(backgroundName)
            bottomBackground.position = CGPoint(
                x: CGFloat(i) * bottomBackground.size.width,
                y: 0)
            bottomBackground.name = "background"
            let topBackground = backgroundNode(backgroundName)
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
    
    func backgroundNode(backgroundName: String) -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPointZero
        
        var background1 = SKSpriteNode(imageNamed: backgroundName)
        background1.anchorPoint = CGPointZero
        background1.position = CGPointZero
        backgroundNode.addChild(background1)
        
        var background2 = SKSpriteNode(imageNamed: backgroundName)
        background2.anchorPoint = CGPointZero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        var background3 = SKSpriteNode(imageNamed: backgroundName)
        background3.anchorPoint = CGPointZero
        background3.position = CGPoint(x: 0, y: background3.size.height)
        backgroundNode.addChild(background3)
        
        var background4 = SKSpriteNode(imageNamed: backgroundName)
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
    //MARK: SOUND EFFECTS BEEP BOOP PSSSSH
    func playRockCollisionSound(){
    }
    
    func playAlienCollisionSound(){
        SKTAudio.sharedInstance().playSoundEffect("rerrr.wav")
    }
    
    //MARK: LEVEL
    
    enum Level {
        case First
        case Second
        case Third
        case Fourth
        case Fifth
    }
    
    func currentLevelIs() -> Level {
        let songTimeAsFloat = self.songDuration as Double
        let timePassedAsFloat = self.timePassed as Double
        let twentyPercent = songTimeAsFloat/5
        let fortyPercent = (songTimeAsFloat/2) * 2
        let sixtyPercent = (songTimeAsFloat/2) * 3
        let eightyPercent = (songTimeAsFloat/2) * 5
        
        switch timePassedAsFloat {
            //first 20% of the song
        case 0..<twentyPercent :
            self.curLevel = .First
        case twentyPercent..<fortyPercent :
            self.curLevel = .Second
        case fortyPercent..<sixtyPercent :
            self.curLevel = .Third
        case sixtyPercent..<eightyPercent :
            self.curLevel = .Fourth
        case eightyPercent..<songTimeAsFloat :
            self.curLevel = .Fifth
        default:
            self.curLevel = .First
        }
        return self.curLevel
    }
    
    //MARK: SKACTION TO SPAWN ENEMIES
    
    func actionToSpawnRocks() {
        rocksOn = true
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnRock),
                SKAction.waitForDuration(1.0)])))
        println("Rock on  scene on now")
    }
    
    func actionToSpawnFireBalls() {
        fireBallOn = true
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnFireball),
                SKAction.waitForDuration(2.0)])))
        println("FireBall on scene on now")
    }
    
    func actionToSpawnAlien() {
        alienOn = true
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnAlien),
                SKAction.waitForDuration(7)])))
        println("Alien on scene on now")
    }
    
    func actionToSpawnBlackHole() {
        blackHoleOn = true
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnBlackHole),
                SKAction.waitForDuration(45)])))
        println("BlackHole on scene on now")
    }
    
    func actionToSpawnDragon() {
        dragonOn = true
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnDragon),
                SKAction.waitForDuration(30)])))
        println("Dragon on scene on now")
    }
    
    

}
