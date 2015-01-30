//
//  GameScene.swift
//  DoctorWizard
//
//  Created by nacnud on 1/26/15.
//  Copyright (c) 2015 codefellows. All rights reserved.


import SpriteKit
import CoreMotion


protocol MainMenuDelegate {

    func restartWithSameSong(usingDefaultSong: Bool)
    func restartWithDifferentSong()
}

class GameScene: SKScene {
    
    let dude: SKSpriteNode = SKSpriteNode(imageNamed: "dude0")
    let blackHole: SKSpriteNode = SKSpriteNode(imageNamed: "blackhole2")
    let dragon : SKSpriteNode = SKSpriteNode(imageNamed: "dragon2")
    let consoleBarLeft : SKSpriteNode = SKSpriteNode(imageNamed: "ConsoleNavBar")
    let consoleBarRight : SKSpriteNode = SKSpriteNode(imageNamed: "ConsoleNavBar")
    
    
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
    var backgroundVerticalDirection: CGFloat = 1.0
    var backgroundHorizontalDirection: CGFloat = 1.0
    var gameStartTime : NSTimeInterval = 0
    var timePassed : NSTimeInterval = 0
    var backgroundImageName = "background0"
    var starsImageName = "starsFinal"
    let motionManager = CMMotionManager()
    
    var altitude: CGFloat = 0
    var curLevel : Level = .First
    
    var healthPoints :CGFloat = 74200

    var didLose = false
    var didWin = false
    var menuDelegate: MainMenuDelegate?
    
    //booleans to determine if enemies are on the field of play
    var rocksOn : Bool = false
    var fireBallOn : Bool = false
    var alienOn : Bool = false
    var blackHoleOn : Bool = false
    var dragonOn : Bool = false
    
    var sequenceDragonActions : [SKAction] = []
    
    //console display labels
    var playTimeRemainingLabel : SKLabelNode?
    var doctorWizardsAltitudeLabel : SKLabelNode?
    var doctorWizardsHealthLabel : SKLabelNode?
    var playTimeRemainingTicker: NSTimeInterval = 0
    var playButtonPressed : Bool = false
    
    
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
        
        //MARK: Game Console  ======================================================================
        
        consoleBarLeft.zPosition = 13
        consoleBarLeft.position = CGPoint(x: 550, y: 220)
        self.addChild(consoleBarLeft)
        
        consoleBarRight.zPosition = 13
        consoleBarRight.position = CGPoint(x: 1500, y: 220)
        self.addChild(consoleBarRight)
        
        
        
        playTimeRemainingLabel = SKLabelNode(fontNamed:"Futura")
        playTimeRemainingLabel?.fontColor = SKColor.redColor()
        playTimeRemainingLabel?.fontSize = 60;
        //playTimeRemainingLabel?.position = CGPoint(x:CGRectGetMinX(self.frame)+250,y:CGRectGetMinY(self.frame)+1250)
        playTimeRemainingLabel?.position = CGPoint(x: 190, y: 220)
        playTimeRemainingLabel?.zPosition = 14
        self.addChild(playTimeRemainingLabel!)
        
        doctorWizardsAltitudeLabel = SKLabelNode(fontNamed:"Futura")
        doctorWizardsAltitudeLabel?.fontColor = SKColor.redColor()
        doctorWizardsAltitudeLabel?.fontSize = 60;
        //doctorWizardsAltitudeLabel?.position = CGPoint(x:CGRectGetMinX(self.frame)+1000,y:CGRectGetMinY(self.frame)+1250)
        doctorWizardsAltitudeLabel?.position = CGPoint(x: 900, y: 220)
        doctorWizardsAltitudeLabel?.zPosition = 14
        self.addChild(doctorWizardsAltitudeLabel!)
        
        
        doctorWizardsHealthLabel = SKLabelNode(fontNamed:"Futura")
        doctorWizardsHealthLabel?.fontColor = SKColor.redColor()
        doctorWizardsHealthLabel?.fontSize = 60;
        //doctorWizardsHealthLabel?.position = CGPoint(x:CGRectGetMinX(self.frame)+1800,y:CGRectGetMinY(self.frame)+1250)
        doctorWizardsHealthLabel?.position = CGPoint(x: 1700, y: 220)
        doctorWizardsHealthLabel?.zPosition = 14
        self.addChild(doctorWizardsHealthLabel!)
        
        
        //add background layers to to mainview
        addMovingBackground(self.backgroundImageName)
        self.addChild(backgroundLayer)
        self.addChild(starLayer)
        
        if motionManager.accelerometerAvailable {
            self.motionManager.accelerometerUpdateInterval = 0.01
            self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) -> Void in
                if error == nil {
                    let verticleData = data.acceleration.x
                    let horizontalData = data.acceleration.y
                    self.backgroundVerticalDirection = CGFloat(verticleData * 50.0)
                    self.backgroundHorizontalDirection = CGFloat(horizontalData * 50.0)
                    
                  //  println("we got acceleromiter data : \(verticleData)")
                }
            })
        }
       
        
    }
    
    //called before each frame is rendered
    override func update(currentTime: NSTimeInterval) {
        
        //validating if it is fifth level only Dragon exists
        
        if currentLevelIs() == .Fifth {
            
            enumerateChildNodesWithName("rock") { node, _ in
                
                let rockNode = node as SKSpriteNode
                rockNode.removeFromParent()
                }
            
            enumerateChildNodesWithName("fireball") { node, _ in
                
                let fireballNode = node as SKSpriteNode
                fireballNode.removeFromParent()
            }
            
            enumerateChildNodesWithName("blackhole") { node, _ in
                
                let blackHoleNode = node as SKSpriteNode
                blackHoleNode.removeFromParent()
            }
            
            enumerateChildNodesWithName("alien") { node, _ in
                
                let alienNode = node as SKSpriteNode
                alienNode.removeFromParent()
            }
        }
        
        
        
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
            if !rocksOn {
                //actionToSpawnRocks()
                println("First scene on now")
            }

        case .Second:
            if !fireBallOn {
                //actionToSpawnFireBalls()
                println("Second scene on now")
            }

        case .Third:
            if !alienOn {
                //actionToSpawnAlien()
                println("Third scene on now")
            }
            
        case .Fourth:
            if !blackHoleOn {
                //actionToSpawnBlackHole()
                println("Fourth scene on now")
            }
        case .Fifth:

            if !dragonOn{
                actionToSpawnDragon()
                println("Fifth scene on now")
            }
            
          //  println("Fifth scene on now")
            
            
        default:
            
            println("DefaultLevel")
        }
        
        if self.healthPoints <= 0 {
            self.healthPoints = 0
            self.didLose = true
        }
        
        
        //MARK: Main Game Consile Display Labels
        
        doctorWizardsAltitudeLabel?.text = "Altitude: \(altitude)"
        
        //I want to start playTimeRemainingTicker after play button was pressed not when game starts
        //if ( playButtonPressed == true ){}
        
        playTimeRemainingTicker = songDuration - timePassed
        
        
        
        if ( playTimeRemainingTicker > 0 ){
            
            
            playTimeRemainingLabel?.text = "TTP: \(playTimeRemainingTicker)"
            
        }else{
            
            
            playTimeRemainingLabel?.text = "TTP: \(0)"
            
            self.didLose = true // and show the you loose label or image
            
            // will create "You Loose" Label or show Duncan Artwork
            
            
        }
        
        
        doctorWizardsHealthLabel?.text = "Health: \(healthPoints)"
        
        
        
        
        
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
        if self.didWin == true{
            self.scene?.paused = true
            let winGameScene = WinScene(size: self.size)
            winGameScene.mainMenuDelegate = self.menuDelegate
            if self.songGenre == "DefaultDuncanSong"{
                winGameScene.isDefaultSong = true
            }
            
            self.view?.presentScene(winGameScene)
            
        }
        checkCollisions()
        destroyedByBlackHole()
        destroyedByDragon()
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
//        self.backgroundVerticalDirection = currentY - previousY
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
        let positionOnScreen = CGPoint(
            x: CGFloat.random(min: -100,
                max: self.size.width + 100),
            y: size.height + 200)
        
        rock.position = backgroundLayer.convertPoint(positionOnScreen, fromNode: self)
        rock.setScale(1)
        rock.zPosition = 0
        self.backgroundLayer.addChild(rock)
        let appear = SKAction.scaleTo(3, duration: 4.0)
        let actions = [appear]
        rock.runAction(SKAction.sequence(actions))
//        let actionMove = SKAction.moveToY(-100, duration: 4.0)
        let moveToPoint = CGPoint(x: rock.position.x, y: -300)
        let actionMove = SKAction.moveTo(backgroundLayer.convertPoint(moveToPoint, fromNode: self), duration: 4.0)
        let actionRemove = SKAction.removeFromParent()
        rock.runAction(SKAction.sequence([actionMove, actionRemove]))}
    
    //MARK: SPAWN FIREBALLS ====================================================================

    func spawnFireball() {
        let fireBall = SKSpriteNode(imageNamed: "fireball")
        let oldPosition = fireBall.position
        let upPosition = oldPosition + CGPoint(x: 0, y: 20)
        let upEffect = SKTMoveEffect(node: fireBall, duration: 0.9, startPosition: oldPosition, endPosition: upPosition)
        upEffect.timingFunction = { t in pow(1, -1 * t) * (sin(t * π * 3))}
        let upAction = SKAction.actionWithEffect(upEffect)
        let upActionRepeat = SKAction.repeatActionForever(upAction)
        
        
        
        fireBall.name = "fireball"
        let screenPosition = CGPoint(x: size.width + 100, y: CGFloat.random(min: 0, max: size.height))
        fireBall.position = backgroundLayer.convertPoint(screenPosition, fromNode: self)
        fireBall.setScale(1)
        fireBall.zPosition = 0
        self.backgroundLayer.addChild(fireBall)
        let appear = SKAction.scaleTo(3, duration: 4.0)
        let actions = [appear]
        fireBall.runAction(SKAction.sequence(actions))
        let actionMove =
        SKAction.moveToX(-300, duration: 3.0)
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

        for index in 1...60 {
        //random variable for dragon movement
        var randomXChooser = CGFloat(Int.random(0...Int(playableRect.width)))
        println(randomXChooser)
        println(size.width)
        var randomYChooser = CGFloat(Int.random(0...Int(playableRect.height)))
        
        switch generateRandomDragonOrientation() {
            
        case 1...5:
            var actionX = SKAction.moveToX(randomYChooser +  (dragon.frame.width / 2), duration: 0.3)
            sequenceDragonActions.append(actionX)
            
        case 6...10:
            
            var actionY = SKAction.moveToY(randomYChooser -  (dragon.frame.height / 2), duration: 0.3)
            sequenceDragonActions.append(actionY)
            
        default:
            println("DefaultLevel")
  
            }
        }
        dragon.name = "dragon"
        println("I made it to spawnDragon")
        dragon.position = CGPoint(
            x: CGFloat.random(min: CGRectGetMinX(playableRect) + dragon.frame.width,
                max: CGRectGetMaxX(playableRect) - dragon.frame.width),
            y: CGFloat.random(min: CGRectGetMinX(playableRect) + dragon.frame.height,
                max: (CGRectGetMaxX(playableRect) - (5 * dragon.frame.height))))
        dragon.setScale(0)
        dragon.zPosition = 0
        addChild(dragon)
        let appear = SKAction.scaleTo(1.3, duration: 1.0)
        dragon.runAction(appear)
        
        let actionDragonAttack = SKAction.sequence(sequenceDragonActions)
        
        //dragon.runAction(SKAction.sequence(sequenceDragonActions))
        
        let actionRemove = SKAction.removeFromParent()
        
        let dragonKillEverything = [actionDragonAttack, actionRemove]
        
        dragon.runAction(SKAction.sequence(dragonKillEverything))
        
    // MAARK: END OF DRAGON SECTION ==============================================================

    }
    
    func generateRandomDragonOrientation() -> Int {
        
        return Int.random(1...10)
        
    }
    
    func runDragonActions(dragonActions : [SKAction]) {
        for index in 0...19 {
            dragon.runAction(dragonActions[index])
        }
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
                    // SKAction that lowers volume and plays collision sound
                    SKTAudio.sharedInstance().backgroundMusicPlayer?.volume = 0.5
                    let action = SKAction.waitForDuration(1.0)
                    self.dude.runAction(action, completion: { () -> Void in
                        self.playRockCollisionSound()
                    })
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
    
    func destroyedByDragon() {
        enumerateChildNodesWithName("dude") { node, _ in
            
            let dudeHit = node as SKSpriteNode
            
            if CGRectIntersectsRect(dudeHit.frame, self.dragon.frame) {
                self.healthPoints = self.healthPoints - 500
            }
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
     
                let angle : CGFloat = -CGFloat(M_PI)
                let oneSpin = SKAction.rotateByAngle(angle, duration: 3.5)
                let repeatSpin = SKAction.repeatActionForever(oneSpin)
                let implode = SKAction.scaleTo(0, duration: 2.0)
                let actionRemove = SKAction.removeFromParent()
                let actionTowardsBlackHoleXCoord = SKAction.moveToX(self.blackHole.position.x, duration: 1.0)
                self.dude.runAction(actionTowardsBlackHoleXCoord)
                let actionTowardsBlackHoleYCoord = SKAction.moveToY(self.blackHole.position.y, duration: 1.0)
                self.dude.runAction(actionTowardsBlackHoleYCoord)
                let actions = [implode, actionRemove]
                dudeHit.runAction(repeatSpin)
                dudeHit.runAction(SKAction.sequence(actions), completion: { () -> Void in
                    if self.invincible == false {
                        self.healthPoints = 0
                    }
                })
            }
        }
        
        enumerateChildNodesWithName("alienspaceship") { node, _ in
            
            let alienHit = node as SKSpriteNode
            
            if CGRectIntersectsRect(alienHit.frame, self.blackHole.frame) {
                alienHit.removeFromParent()
                
            }
        }
    }
    /* in progress */
    func actionSpiralIntoBlackHole (passedInNode: SKSpriteNode ) {
        let angle : CGFloat = -CGFloat(M_PI)
        let oneSpin = SKAction.rotateByAngle(angle, duration: 3.5)
        let repeatSpin = SKAction.repeatActionForever(oneSpin)
        let implode = SKAction.scaleTo(0, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        let actions = [implode, actionRemove]
        passedInNode.runAction(repeatSpin)
        passedInNode.runAction(SKAction.sequence(actions))
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
            x: self.backgroundHorizontalDirection * 60,
            y: self.backgroundVerticalDirection *  60)
        let ammountToMove = backgroundVelocity * CGFloat(dt)
        self.backgroundLayer.position += ammountToMove
        
        backgroundLayer.enumerateChildNodesWithName("background", usingBlock: { (node, _) -> Void in
            let background = node as SKSpriteNode
            let backgroundScreenPos = self.backgroundLayer.convertPoint(background.position, toNode: self)
            if backgroundScreenPos.x <= -background.size.width {
                background.position.x = background.position.x + background.size.width*2
            }
            if backgroundScreenPos.x >= background.size.width {
                background.position.x = background.position.x - background.size.width*2
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
            x: self.backgroundHorizontalDirection * 100,
            y: self.backgroundVerticalDirection *  100)
        let ammountToMove = backgroundVelocity * CGFloat(dt)
        self.starLayer.position += ammountToMove
        
        starLayer.enumerateChildNodesWithName("stars", usingBlock: { (node, _) -> Void in
            let background = node as SKSpriteNode
            let backgroundScreenPos = self.starLayer.convertPoint(background.position, toNode: self)
            if backgroundScreenPos.x <= -background.size.width {
                background.position.x = background.position.x + background.size.width*2
            }
            if backgroundScreenPos.x >= background.size.width {
                background.position.x = background.position.x - background.size.width*2
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
        let randomNum = CGFloat.random(min: 0, max: 4)
        switch randomNum{
        case 0..<1 :
            SKTAudio.sharedInstance().playSoundEffect("clicks_one.wav")
        case 1..<2 :
            SKTAudio.sharedInstance().playSoundEffect("blop_eleven.wav")
        case 2..<3 :
            SKTAudio.sharedInstance().playSoundEffect("blop_four.wav")
        case 3...4 :
            SKTAudio.sharedInstance().playSoundEffect("blop_nine.wav")

        default:
            println("fucked something up")
        }

        SKTAudio.sharedInstance().backgroundMusicPlayer?.volume = 1.0
    }
    
    func playAlienCollisionSound(){
        let randomNum = CGFloat.random(min: 1, max: 2)
        if randomNum <= 1 {
            SKTAudio.sharedInstance().playSoundEffect("rerrr.wav")
        }else{
            SKTAudio.sharedInstance().playSoundEffect("blop_seven.wav")
        }
    
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
        var timePassedAsFloat : Double
        if (self.timePassed as Double) < songTimeAsFloat{
            timePassedAsFloat = self.timePassed as Double
        }else{
            timePassedAsFloat = songTimeAsFloat
        }
        let twentyPercent = songTimeAsFloat/5
        let fortyPercent = (songTimeAsFloat/5) * 2
        let sixtyPercent = (songTimeAsFloat/5) * 3
        let eightyPercent = (songTimeAsFloat/5) * 4
        
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
            self.didWin = true
            println("you win:")
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
                SKAction.waitForDuration(20)])))
        println("Dragon on scene on now")
    }
    
    //MARK: start acceleromiter updates
    



    
    

}
