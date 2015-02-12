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
    var singleDragon : SKSpriteNode = SKSpriteNode(imageNamed: "dragon2")
    var blackHole : SKSpriteNode = SKSpriteNode(imageNamed: "blackhole2")
    
    var dudeDirection:String = "right"
    
    let magicEmitter = SKEmitterNode(fileNamed: "Fire.sks")

    let dudeAnimationRight : SKAction
    let dudeAnimationLeft : SKAction
    
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
    // timing variables
    var gameStartTime : NSTimeInterval = 0
    var gamePausedAt : NSTimeInterval?
    var timePassed : NSTimeInterval = 0
    var currentClock : NSTimeInterval = 0
    
    var backgroundImageName = "background0"
    var starsImageName = "starsFinal"
    let motionManager = CMMotionManager()
    var rocks : [String] = []
    
    var altitude: CGFloat = 0
    var curLevel : Level = .First
    
    var healthPoints :CGFloat = 742

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
    var dragon : [SKSpriteNode] = []
    var dragonCounter : Int = 0
    
    //console display labels
    var playTimeRemainingLabel : SKLabelNode?
    var doctorWizardsAltitudeLabel : SKLabelNode?
    var doctorWizardsHealthLabel : SKLabelNode?
    var playTimeRemainingTicker: NSTimeInterval = 0
    var playButtonPressed : Bool = false
    var backgroundSizeFrame : CGRect = CGRect(x: 0, y: 0, width: 4096, height: 3027)
    let consoleBarLeft : SKSpriteNode = SKSpriteNode(imageNamed: "DrWizardConsoleBarExtender")
    let consoleBarRight : SKSpriteNode = SKSpriteNode(imageNamed: "DrWizardConsoleBarExtender")
    let consoleBar : SKSpriteNode = SKSpriteNode(imageNamed: "drWizardConsoleBar_3000_wLabels")
    
    let dudesHealthGague: CGRect
    
    
    
    
    var alienHitRocks = 15
    
    
    //MARK: INTIALIZER ==============================================================================
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        
        playableRect = CGRect(x: 0, y: playableMargin,
            width: size.width,
            height: playableHeight) // 4
        
        dudesHealthGague = CGRect(x: CGRectGetMinX(playableRect)+1700, y: CGRectGetMinY(playableRect)+350,
            width: 200,
            height: 30)
        //dudesHealthGague = SKColor(colorWithRed:0.15, green:0.15, blue:0.3, alpha:1.0)
        
        // setup dude_animation
        var texturesRight: [SKTexture] = []
        var texturesLeft: [SKTexture] = []
        for i in 0...10 {
            
            texturesRight.append(SKTexture(imageNamed: "dude\(i)" ))
            texturesLeft.append(SKTexture(imageNamed: "dudeLeft\(i)"))

        }
        
        self.dudeAnimationRight = SKAction.repeatActionForever(SKAction.animateWithTextures(texturesRight, timePerFrame: 0.1))
        self.dudeAnimationLeft = SKAction.repeatActionForever(SKAction.animateWithTextures(texturesLeft, timePerFrame: 0.1))
        
        super.init(size: size)
        setupParticles()
        //createMagic()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    

    //MARK: DID MOVE TO VIEW ======================================================================
    
    override func didMoveToView(view: SKView) {
        
//        dude.position = CGPoint(x: 700, y: 400)
        let centerScreen = self.convertPoint(CGPoint(x: 1024, y: 676), fromNode: self.backgroundLayer)
        dude.position = centerScreen
        dude.zPosition = 15
        dude.setScale(0.75)
        dude.runAction(SKAction.repeatActionForever(dudeAnimationRight))
        dude.name = "dude"

        //clockfix
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackground", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        
        //simulate SKSpriteNode for collision purposes

        
        //MARK: Game Console  ======================================================================

        
        //Main console bar
        
            consoleBar.zPosition = 15
            consoleBar.position = CGPoint(x: 1020, y: 248)
            //consoleBar.anchorPoint = CGPointZero
            //consoleBar.position = CGPoint(x:CGRectGetMinX(self.frame)+1020,y:CGRectGetMinY(self.frame)+248)
            //consoleBar.position = CGPointZero
        
        //console bar extender left for bigger screens
            consoleBarLeft.zPosition = 15
            consoleBarLeft.position = CGPoint(x: 0, y: 248)
            //consoleBarLeft.position = CGPoint(x:CGRectGetMinX(self.frame)+0,y:CGRectGetMinY(self.frame)+248)
            self.addChild(consoleBarLeft)
        
        //console bar extenders right for bigger screens
            consoleBarRight.zPosition = 15
            consoleBarRight.position = CGPoint(x: 1500, y: 248)
            //consoleBarRight.position = CGPoint(x:CGRectGetMinX(self.frame)+1500,y:CGRectGetMinY(self.frame)+248)
            self.addChild(consoleBarRight)
        
        self.addChild(consoleBar)
        
        
        
        //Get your rocks on
        
        for i in 1...5 {
            rocks.append("pinkRock\(i)")
        }
        
        playTimeRemainingLabel = SKLabelNode(fontNamed:"Futura")
        playTimeRemainingLabel?.fontSize = 40;
            if ( playTimeRemainingTicker <= 15 ){
                playTimeRemainingLabel?.fontColor = SKColor.blueColor()
            }else{
                playTimeRemainingLabel?.fontColor = SKColor.redColor()
            }
        //playTimeRemainingLabel?.position = CGPoint(x: 560, y: 213)
        playTimeRemainingLabel?.position = CGPoint(x:CGRectGetMinX(self.frame)+545,y:CGRectGetMinY(self.frame)+213)
        playTimeRemainingLabel?.zPosition = 16
        self.addChild(playTimeRemainingLabel!)
        
        
        doctorWizardsAltitudeLabel = SKLabelNode(fontNamed:"Futura")
        doctorWizardsAltitudeLabel?.fontColor = SKColor.blueColor()
        doctorWizardsAltitudeLabel?.fontSize = 40;
        //doctorWizardsAltitudeLabel?.position = CGPoint(x: 1031, y: 198)
        doctorWizardsAltitudeLabel?.position = CGPoint(x:CGRectGetMinX(self.frame)+1031,y:CGRectGetMinY(self.frame)+198)
        doctorWizardsAltitudeLabel?.zPosition = 16
        self.addChild(doctorWizardsAltitudeLabel!)
        
        
        doctorWizardsHealthLabel = SKLabelNode(fontNamed:"Futura")
        doctorWizardsHealthLabel?.fontColor = SKColor.redColor()
        doctorWizardsHealthLabel?.fontSize = 45;
        //doctorWizardsHealthLabel?.position = CGPoint(x: 1700, y: 350)
        doctorWizardsHealthLabel?.position = CGPoint(x:CGRectGetMinX(self.frame)+1840,y:CGRectGetMinY(self.frame)+213)
        
        doctorWizardsHealthLabel?.zPosition = 16
        self.addChild(doctorWizardsHealthLabel!)
        
        
        //add background layers to to mainview
        addMovingBackground(self.backgroundImageName)
        self.addChild(backgroundLayer)
        self.addChild(starLayer)
        self.backgroundLayer.addChild(dude)
        
        
        //add magic emitter
        magicEmitter.position = CGPoint(x: -10, y: 15)
        dude.addChild(magicEmitter)
        
        if motionManager.accelerometerAvailable {
            self.motionManager.accelerometerUpdateInterval = 0.1
            self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) -> Void in
                if error == nil {
                    let verticalData = data.acceleration.x
                    let horizontalData = data.acceleration.y
                    self.backgroundVerticalDirection = CGFloat(verticalData * 50.0)
                    self.backgroundHorizontalDirection = CGFloat(horizontalData * 50.0)
                    
                  //  println("we got acceleromiter data : \(verticleData)")
                }
            })
        }
       
        
    }
    
    func didEnterBackground(){
            self.gamePausedAt = lastUpdateTime

    }
    func didEnterForeground(){
        let currentTime = CACurrentMediaTime()
// the new start time should be == old start time + time passed since pause
        let timePaused = currentTime - gamePausedAt!
        self.lastUpdateTime = self.lastUpdateTime + timePaused
    }
    
    //called before each frame is rendered
    override func update(currentTime: NSTimeInterval) {

        //validating if it is fifth level only Dragon exists

        
        //MARK: stop all nodes other than dragon
//        if currentLevelIs() == .Fifth {
//            
//            enumerateChildNodesWithName("rock") { node, _ in
//                
//                let rockNode = node as SKSpriteNode
//                rockNode.removeFromParent()
//                }
//            
//            enumerateChildNodesWithName("fireball") { node, _ in
//                
//                let fireballNode = node as SKSpriteNode
//                fireballNode.removeFromParent()
//            }
//            
//            enumerateChildNodesWithName("blackhole") { node, _ in
//                
//                let blackHoleNode = node as SKSpriteNode
//                blackHoleNode.removeFromParent()
//            }
//            
//            enumerateChildNodesWithName("alien") { node, _ in
//                
//                let alienNode = node as SKSpriteNode
//                alienNode.removeFromParent()
//            }
//        }
//        
        if self.paused == false {
            if gameStartTime == 0 {
                gameStartTime = currentTime
            }
            
            if lastUpdateTime > 0 {
                dt = currentTime - lastUpdateTime
            } else {
                dt = 0
            }
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
        
        
        //MARK: SET TIMEPASSED ======================================
        if self.paused == false {
            
            self.timePassed += round(NSTimeInterval(self.dt)*1000)/1000
            println("timePassed = \(timePassed)")
        }
        
        println(self.dt)
        
        //MARK: set altitude variable
        //if timePassed % 0.5 == 0 { 
        //That won't work anymore 'cause timePassed variable type changed from a float to an NSTimeInterval.
        
            if self.backgroundVerticalDirection < 0 {
                self.altitude += 1
            } else if self.backgroundVerticalDirection > 0 {
                self.altitude -= 1
            }
        //}
        
        
        if self.backgroundHorizontalDirection > 0 && self.dudeDirection != "left" {
            self.dude.removeAllActions()
            self.dude.runAction(SKAction.repeatActionForever(dudeAnimationLeft))
            self.dudeDirection = "left"
        } else if self.backgroundHorizontalDirection < 0 && self.dudeDirection != "right" {
            self.dude.removeAllActions()
            self.dude.runAction(SKAction.repeatActionForever(dudeAnimationRight))
            self.dudeDirection = "right"
        }
        
        self.dude.position = self.backgroundLayer.convertPoint(CGPoint(x: self.size.width/2, y: self.size.height/2), fromNode: self)
        
        //magicEmitter
        let magicEmitterCGPoint = CGPoint(x: backgroundHorizontalDirection, y: backgroundVerticalDirection)
        let magicEmitterAngle = magicEmitterCGPoint.angle
        self.magicEmitter.emissionAngle = CGFloat(magicEmitterAngle)
        
        //Sections that determines which enemmies come to playing field based on Level of tune
        
        switch currentLevelIs()
        {
            
        case .First:
            if !rocksOn {
                actionToSpawnRocks()
                println("First scene on now")
            }
            
        case .Second:
            if !fireBallOn {
                actionToSpawnFireBalls()
                println("Second scene on now")
            }

        case .Third:
            if !alienOn {
                actionToSpawnAlien()
                println("Third scene on now")
            }
            
        case .Fourth:
            if !blackHoleOn {
                actionToSpawnBlackHole()
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
        
        
        
        //MARK: GAME CONSOLE < Playtime Remaining | Altitude | Health >-------------------------------------
        
        
            //MARK: Display Playtime Remaining Label
        
        
                playTimeRemainingTicker = songDuration - timePassed

        
                    if ( playTimeRemainingTicker > 0 ){
            
                            playTimeRemainingLabel?.text = "\(nSTimeIntervalValueToString(playTimeRemainingTicker,decimalPlaceRequired: 0))"
            
                    }else{
            
                            playTimeRemainingLabel?.text = "\(0)"
            
                            self.didWin = true // and show the you loose screen
                    }
        
        
         //MARK: Display Spaceman's Altitude Label
        
            doctorWizardsAltitudeLabel?.text = "\(altitude)"
        
        
        
         //MARK: Display Spaceman's Health Status Label
        
            var fullHealthStatus: CGFloat = 742.0
        
            let healthyIconEmoji: String = "🍏"
            let unhealthyIconEmoji: String = "🍊"
            let expiredEmoji: String = "😑"

        
        
                if (healthPoints == 0 ){
                        //Player is spacedust
                        doctorWizardsHealthLabel?.text = "\(expiredEmoji)"
                }else{
        
        
                        //strongest >= 80%
                    if (healthPoints >= fullHealthStatus*0.8 && healthPoints <= fullHealthStatus){
                            //println("strongest condition reached")
                            doctorWizardsHealthLabel?.text = "\(healthyIconEmoji)\(healthyIconEmoji)\(healthyIconEmoji)\(healthyIconEmoji)\(healthyIconEmoji)"
                    }
        
                        //strong <= 80% && >=60%
                    if(healthPoints <= fullHealthStatus*0.8 && healthPoints >= fullHealthStatus*0.6){
                            //println("strong condition reached")
                            doctorWizardsHealthLabel?.text = "\(healthyIconEmoji)\(healthyIconEmoji)\(healthyIconEmoji) \(healthyIconEmoji)"
                    }
        
                        //ok <= 60% && >=40%
                    if(healthPoints <= fullHealthStatus*0.6 && healthPoints >= fullHealthStatus*0.4){
                            //println("ok condition reached")
                            doctorWizardsHealthLabel?.text = "\(healthyIconEmoji)\(healthyIconEmoji)\(healthyIconEmoji)"
                    }
        
                        //weak <= 40% && >=20%
                    if(healthPoints <= fullHealthStatus*0.4 && healthPoints >= fullHealthStatus*0.2){
                            //println("weak condition reached")
                            doctorWizardsHealthLabel?.text = "\(unhealthyIconEmoji)\(unhealthyIconEmoji)"
                    }
        
                        //weakest <= 20%
                        if(healthPoints <= fullHealthStatus*0.2){
                            //println("weakest condition reached")
                            doctorWizardsHealthLabel?.text = "\(unhealthyIconEmoji)"
                        }
        
                    }
        
        
          //E.O. GAME CONSOLE DISPLAY LABELS -------------------------------------
        
        
        if self.alienHitRocks <= 0 {
            enumerateChildNodesWithName("alienspaceship", usingBlock: { (node, _) -> Void in
                let alien = node as SKSpriteNode
                alien.removeFromParent()
            })
        }
        
        
       
//        boundsCheckDude()
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
    
    //MARK: PARTICLE SYSTEMS ========================================================================
    func particleEmitterNode(#speed: CGFloat, lifetime: CGFloat, scale: CGFloat, birthRate: CGFloat, color: SKColor) -> SKEmitterNode {
//        let star = SKLabelNode(fontNamed: "Helvetica")
//        star.fontSize = 80.0
//        star.text = "🔹"
//        let textureView = SKView()
//        let texture = textureView.textureFromNode(star)
//        texture.filteringMode = .Nearest
        
        let emitterNode = SKEmitterNode()
        emitterNode.particleTexture = SKTexture(imageNamed: "bokeh.png")
        emitterNode.particleBirthRate = birthRate
        emitterNode.particleColor = color
        emitterNode.particleLifetime = lifetime
        emitterNode.particleSpeed = speed
        emitterNode.particleScale = scale
        emitterNode.particleColorBlendFactor = 1
        emitterNode.position = CGPoint(x: CGRectGetMaxX(frame) * 0.75, y: CGRectGetMaxY(frame))
        emitterNode.particlePositionRange = CGVector(dx: CGRectGetMaxX(frame), dy: 0)
        
        //not in setupParticles() :
        emitterNode.emissionAngle = CGFloat(M_PI_4)
        emitterNode.particleAction = SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(M_PI_4), duration: 1))

        let sparkles = 10
        let colorSequence = SKKeyframeSequence(capacity: sparkles * 2)
        let sparkleTime = 1.0 / CGFloat(sparkles)
        for i in 0..<sparkles {
            colorSequence.addKeyframeValue(SKColor.whiteColor(), time: CGFloat(i) * 2 * sparkleTime/2)
            colorSequence.addKeyframeValue(SKColor.blueColor(), time: (CGFloat(i) * 2+1) * sparkleTime/2)
        }
        emitterNode.particleColorSequence = colorSequence
        
        emitterNode.advanceSimulationTime(NSTimeInterval(lifetime))
        return emitterNode
    }
    
    // dust particles
    func setupParticles() {
        let dustTrailNode = SKNode()
        dustTrailNode.name = "dustTrailNode"
        dustTrailNode.addChild(particleEmitterNode(speed: -400, lifetime: (size.height / 100), scale: 0.3, birthRate: 1, color: SKColor.lightGrayColor()))
        dustTrailNode.zPosition = 20
        addChild(dustTrailNode)
        
        var emitterNode = particleEmitterNode(speed: -240, lifetime: (size.height / 50), scale: 0.2, birthRate: 2, color: SKColor.yellowColor())
        emitterNode.zPosition = -1
        //emitterNode.position = CGPoint(x: 0, y: CGRectGetMaxY(frame))
        dustTrailNode.addChild(emitterNode)
        
        emitterNode = particleEmitterNode(speed: -100, lifetime: size.height / 20, scale: 0.1, birthRate: 1, color: SKColor.redColor())
        emitterNode.zPosition = 20
        //emitterNode.position = CGPoint(x: 0, y: CGRectGetMaxY(frame))

        dustTrailNode.addChild(emitterNode)
        
    }
    
    // dude particles
//    func createMagic() {
//            let magicEmitter = SKEmitterNode(fileNamed: "Fire.sks")
//                magicEmitter.position = CGPoint(x: 1, y: -4)
//            magicEmitter.name = "magicEmitter"
//            addChild(magicEmitter)
//    }
    
    //MARK: SPAWN ROCKS ========================================================================
// old spawnRock
//    func spawnRock() {
//        let rock = SKSpriteNode(imageNamed: "Rock")
//        rock.name = "rock"
//        let positionOnScreen = CGPoint(
//            x: CGFloat.random(min: -100,
//                max: self.size.width + 100),
//            y: size.height + 200)
//        
//        rock.position = backgroundLayer.convertPoint(positionOnScreen, fromNode: self)
//        rock.setScale(1)
//        rock.zPosition = 0
//        self.backgroundLayer.addChild(rock)
//        let appear = SKAction.scaleTo(3, duration: 4.0)
//        let actions = [appear]
//        rock.runAction(SKAction.sequence(actions))
////        let actionMove = SKAction.moveToY(-100, duration: 4.0)
//        let moveToPoint = CGPoint(x: rock.position.x, y: -300)
//        let actionMove = SKAction.moveTo(backgroundLayer.convertPoint(moveToPoint, fromNode: self), duration: 4.0)
//        let actionRemove = SKAction.removeFromParent()
//        rock.runAction(SKAction.sequence([actionMove, actionRemove]))
//    }
    
    func spawnRock(){
        let chooseRockNum = Int(CGFloat.random(min: 1, max: 5))
        let rock = SKSpriteNode(imageNamed: self.rocks[chooseRockNum])
        rock.name = "rock"
        rock.position = self.backgroundLayer.convertPoint(randomSpawnPoint(), fromNode: self)
        // exclusive or checks to determin that the rock will not spawn on  the player!

            if spawnWontHitPlayer(position) {
                rock.setScale(0)
                rock.alpha = 0
                rock.zRotation = CGFloat.random(min: 0, max: 90)
                self.backgroundLayer.addChild(rock)
                let duration = NSTimeInterval(CGFloat.random(min: 0, max: 10))
                let grow = SKAction.scaleTo(CGFloat.random(min: 0.5, max: 2.4), duration: duration)
                let fade = SKAction.fadeAlphaTo(0.6, duration: duration/10)
                let wait = SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 4, max: 15)))
                let appear = SKAction.group([grow,fade])
                let reverseGrow = SKAction.scaleTo(0, duration: duration/5)
                let reverseFade = SKAction.fadeAlphaTo(0, duration: duration/5)
                let disopear = SKAction.group([reverseFade, reverseGrow])
                let remove = SKAction.removeFromParent()
                let curentLevel = currentLevelIs()
                if curentLevel == .First || curentLevel == .Second {
                    let seq = SKAction.sequence([appear,wait,disopear, remove])
                    rock.runAction(seq)
                } else {
                    let positionToDouble = randomSpawnPoint()
                    let moveToPositon = positionToDouble * 2
                    let convertedPositon = self.backgroundLayer.convertPoint(positionToDouble, fromNode: self)
                    let move = SKAction.moveTo(convertedPositon, duration: NSTimeInterval(CGFloat.random(min: 8, max: 12)))
                    let moveApear = SKAction.group([grow,move,fade])
                    rock.runAction(SKAction.sequence([moveApear, disopear, remove]))
                }
            }


    }
    
    func spawnWontHitPlayer(spawnPoint: CGPoint) -> Bool {
        if spawnPoint.x > self.dude.position.x + 50 && !( spawnPoint.x < self.dude.position.x - 50) || !(spawnPoint.x > self.dude.position.x + 50) && ( spawnPoint.x < self.dude.position.x - 50){
            if (spawnPoint.y > self.dude.position.y  + 50) && !(spawnPoint.y < self.dude.position.y - 50)  || !(spawnPoint.y > self.dude.position.y  + 50) && (spawnPoint.y < self.dude.position.y - 50) {
                return true
            }
        }
        return false
    }
    

    func randomSpawnPoint() -> CGPoint {
        let posX : CGFloat = CGFloat.random(min: 0, max: 4096) - 1024
        let posY : CGFloat = CGFloat.random(min: 0, max: 3072) - 767
        let position = CGPoint(x: posX, y: posY)
        return position
    }
    
    
    
// func randomPointInNode(node:SKNode) -> CGPoint {
//        return CGPoint(x: CGFloat.random(min: 0, max: CGRectGetMaxX(node.frame)), y: CGFloat.random(min: 0, max: CGRectGetMaxY(node.frame)))
//    }
    
    //MARK: SPAWN FIREBALLS ====================================================================

//    func spawnFireball() {
//        let fireBall = SKSpriteNode(imageNamed: "fireball")
//        let oldPosition = fireBall.position
//        let upPosition = oldPosition + CGPoint(x: 0, y: 20)
//        let upEffect = SKTMoveEffect(node: fireBall, duration: 0.9, startPosition: oldPosition, endPosition: upPosition)
//        upEffect.timingFunction = { t in pow(1, -1 * t) * (sin(t * π * 3))}
//        let upAction = SKAction.actionWithEffect(upEffect)
//        let upActionRepeat = SKAction.repeatActionForever(upAction)
//        
//        
//        
//        fireBall.name = "fireball"
//        let screenPosition = CGPoint(x: size.width + 100, y: CGFloat.random(min: 0, max: size.height))
//        fireBall.position = backgroundLayer.convertPoint(screenPosition, fromNode: self)
//        fireBall.setScale(1)
//        fireBall.zPosition = 0
//        self.backgroundLayer.addChild(fireBall)
//        let appear = SKAction.scaleTo(3, duration: 4.0)
//        let actions = [appear]
//        fireBall.runAction(SKAction.sequence(actions))
//        let actionMove =
//        SKAction.moveToX(-300, duration: 3.0)
//        let actionRemove = SKAction.removeFromParent()
//        fireBall.runAction(SKAction.sequence([SKAction.group([upAction, actionMove]),actionRemove]))
//    }
    
    func spawnFireball(){
        let fireball = SKSpriteNode(imageNamed: "fireball")
        let warning = SKSpriteNode(imageNamed: "Rock")
        fireball.name = "fireball"
        fireball.position = self.backgroundLayer.convertPoint(generateFireballSpawnPoint(), fromNode: self)
        var warnignPosition =  self.convertPoint(fireball.position, fromNode: self.backgroundLayer)
        warnignPosition = CGPoint(x: self.size.width - (self.size.width/8), y: warnignPosition.y)
        warning.position = warnignPosition
        warning.alpha = 0
        
        addChild(warning)
        fireball.setScale(1)
        fireball.zPosition = 0
        self.backgroundLayer.addChild(fireball)
        let remove = SKAction.removeFromParent()
        let warningApear = SKAction.fadeAlphaTo(1, duration: 0.1)
        let warningDisopear = SKAction.fadeAlphaTo(0, duration: 0.2)
        let displayWarning = SKAction.sequence([SKAction.repeatAction(SKAction.sequence([warningApear,warningDisopear ]), count: 4), remove])
        warning.runAction(displayWarning)
        
        let moveUp = SKAction.moveToY(fireball.position.y + 20, duration: 0.5)
        let moveDown = SKAction.moveToY(fireball.position.y - 20, duration: 0.5)
        var speed :CGFloat = 0.0

        let wiggle = SKAction.repeatActionForever(SKAction.sequence([moveDown,moveUp]))
        
//        let moveAcross = SKAction.moveToX(-1024, duration: NSTimeInterval(CGFloat.random(min: 1, max: 2)))
        var moveTO = self.backgroundLayer.convertPoint(CGPoint(
            x: -1024, y: 0), fromNode: self)
        moveTO.y = fireball.position.y
        let moveAcross = SKAction.sequence([SKAction.moveTo(moveTO, duration: 1.3), remove])

        let move = SKAction.group([wiggle, moveAcross])
        fireball.runAction(move)
        
    }
    
    func generateFireballSpawnPoint() -> CGPoint{
        let posX = CGFloat(3072)
        let posY : CGFloat = CGFloat.random(min: 0, max: 3072) - 767
        return CGPoint(x: posX, y: posY)
    }

    //MARK: SPAWN ALIENS ======================================================================
    
//    func spawnAlien() {
//        let alien = SKSpriteNode(imageNamed: "alienspaceship")
//        alien.name = "alienspaceship"
//        let positionOnScreen = CGPoint(
//            x: CGFloat.random(min: CGRectGetMinX(playableRect) + alien.frame.size.width,
//                max: CGRectGetMaxX(playableRect)),
//            y: size.height)
//        alien.position = backgroundLayer.convertPoint(positionOnScreen, fromNode: self)
//        alien.setScale(1)
//        alien.zPosition = 0
//        backgroundLayer.addChild(alien)
//        var randomXPosition = CGFloat.random(min: 0, max: size.width)
//        var randomYPosition = CGFloat.random(min: 0, max: size.height)
//        let appear = SKAction.scaleTo(1, duration: 2.0)
//        let moveToY = backgroundLayer.convertPoint(CGPoint(x: 0, y: randomYPosition), fromNode: self)
//        let moveToX = backgroundLayer.convertPoint(CGPoint(x: randomXPosition, y: 0), fromNode: self)
////        let actionMoveYDown =
////        SKAction.moveToY(0, duration: 2.0)
////        let actionMoveX =
////        SKAction.moveToX(randomXPosition, duration: 0.5)
////        let actionMoveYUp =
//        
//        let actionMoveY = SKAction.moveTo(moveToY, duration: 2.0)
//        let actionMoveX = SKAction.moveTo(moveToX, duration: 1.0)
//        SKAction.moveToY(size.height - alien.frame.height / 2, duration: 4.0)
//
//        let actionRemove = SKAction.removeFromParent()
//        alien.runAction(SKAction.sequence([appear, actionMoveX, actionMoveY, actionRemove]))}
    
    
    func spawnAlien() {
        let alien = SKSpriteNode(imageNamed: "Spaceship")
        alien.name = "alienspaceship"
        alien.position = randomSpawnPoint()
        alien.zRotation = CGFloat.random(min: 0, max: 90)
        var directions : [SKAction] = []
        var points : [CGPoint] = []
        points.append(self.dude.position)

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
        
        self.backgroundLayer.addChild(alien)

        
        let move = SKAction.moveTo(self.dude.position, duration: 3)
        let wait = SKAction.waitForDuration(1)
        alien.runAction(SKAction.sequence([move,wait, SKAction.sequence(directions)]))
        
    }
    

    
    
    //MARK: BLACK HOLE =========================================================================
    
    func spawnBlackHole() {
        
        blackHole.name = "blackhole"
        //logic to detect where blackhole should land based on it massive size and powerful feature
        
        let posX : CGFloat = CGFloat.random(min: 0, max: 2048)
        let posY : CGFloat = CGFloat.random(min: 0, max: 1596)
        let position = CGPoint(x: posX, y: posY)
        
        //let centerScreen = self.backgroundLayer.convertPoint(CGPoint(x: 1024, y: 676), fromNode: self)
        let centerScreen = self.backgroundLayer.convertPoint(position, fromNode: self)
        blackHole.position = centerScreen
        
        //blackHole.position = self.backgroundLayer.convertPoint(position, fromNode: self)
        
       
        blackHole.setScale(0)
        blackHole.zPosition = 3
        self.backgroundLayer.addChild(blackHole)
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
        
        singleDragon = SKSpriteNode(imageNamed: "dragon2")
        dragon.append(singleDragon)

        for index in 1...60 {
        //random variable for dragon movement
        var randomXChooser = CGFloat(Int.random(0...Int(playableRect.width)))
        var randomYChooser = CGFloat(Int.random(0...Int(playableRect.height)))
        
        switch generateRandomDragonOrientation() {
            
        case 1...5:
            let actionXPoint = self.backgroundLayer.convertPoint(randomSpawnPoint(), fromNode: self)
            var actionX = SKAction.moveTo(actionXPoint, duration: 1)
            sequenceDragonActions.append(actionX)
            
        case 6...10:
            
            var actionYPoint = self.backgroundLayer.convertPoint(randomSpawnPoint(), fromNode: self)
            

            let actionY = SKAction.moveTo(actionYPoint, duration: 1)
            sequenceDragonActions.append(actionY)
            
        default:
            println("DefaultLevel")
  
            }
        }
        dragon[dragonCounter].name = "dragon"
        println("I made it to spawnDragon")

        var dragonSpawnPoint = randomSpawnPoint()
        dragonSpawnPoint /= 2
        dragonSpawnPoint.x += 1024
        dragonSpawnPoint.y += 767
        dragon[dragonCounter].position = dragonSpawnPoint
        dragon[dragonCounter].setScale(0)
        dragon[dragonCounter].zPosition = 0
        self.backgroundLayer.addChild(dragon[dragonCounter])
        let appear = SKAction.scaleTo(1.3, duration: 1)
        dragon[dragonCounter].runAction(appear)
        
        let actionDragonAttack = SKAction.sequence(sequenceDragonActions)
        
        //dragon.runAction(SKAction.sequence(sequenceDragonActions))
        
        let actionRemove = SKAction.removeFromParent()
        
        let dragonKillEverything = [actionDragonAttack, actionRemove]
        
        dragon[dragonCounter].runAction(SKAction.sequence(dragonKillEverything))
        
        dragonCounter++
        //println(dragonCounter)

    }
    
    // MAARK: END OF DRAGON SECTION ==============================================================
    
    func generateRandomDragonOrientation() -> Int {
        
        return Int.random(1...10)
        
    }
    
    func runDragonActions(dragonActions : [SKAction]) {
        for index in 0...19 {
            dragon[dragonCounter].runAction(dragonActions[index])
        }
    }
    
    
    //MARK: COLLISIONS ==========================================================================
    
    func dudeHitObject(enemy: SKSpriteNode) {
        //here dude beceomes invincible and blinks when hit by a rock
        invincible = true
        


        let fadeOut = SKAction.fadeAlphaTo(0, duration: 0.1)
        let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.1)
        let blink = SKAction.repeatAction(SKAction.sequence([fadeOut, fadeIn]), count: 3)
        let disableInvincible = SKAction.runBlock() {
            self.invincible = false
            println("slfkjdlsfj")
        }
        dude.runAction(SKAction.sequence([blink, disableInvincible]))
    }
    
    func checkCollisions() {
        
        var hitObstacle: [SKSpriteNode] = []
        
        self.backgroundLayer.enumerateChildNodesWithName("rock") { node, _ in
            
            let rockHit = node as SKSpriteNode

            if CGRectIntersectsRect(rockHit.frame, self.dude.frame) {
                hitObstacle.append(rockHit)
                self.velocity = CGPoint(x:0, y:0)
                if self.invincible == false {
                    self.dudeHitObject(rockHit)
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
        
        
        
        self.backgroundLayer.enumerateChildNodesWithName("fireball") { node, _ in
            
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
//        for incomingObject in hitObstacle {
//            dudeHitObject(incomingObject)
//        }
        
    }
    
    func destroyedByDragon() {
      self.backgroundLayer.enumerateChildNodesWithName("dragon") { node, _ in
            
            let dragon = node as SKSpriteNode
            
            if CGRectIntersectsRect(dragon.frame, self.dude.frame) {
                self.healthPoints = self.healthPoints - 200
            }
        }
    }
    
    func destroyedByBlackHole() {
        
        self.backgroundLayer.enumerateChildNodesWithName("rock") { node, _ in
            
            let rockHit = node as SKSpriteNode
            if CGRectIntersectsRect(rockHit.frame, self.blackHole.frame) {
                rockHit.removeFromParent()
            }
            
        }
        
        self.backgroundLayer.enumerateChildNodesWithName("fireball") { node, _ in
            
            let fireballHit = node as SKSpriteNode
            
            if CGRectIntersectsRect(fireballHit.frame, self.blackHole.frame) {
                fireballHit.removeFromParent()
            }
        }
        
        self.backgroundLayer.enumerateChildNodesWithName("dude") { node, _ in
            
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
            self.backgroundSizeFrame = bottomBackground.frame
            
            
            
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
        if self.songGenre == "DefaultDuncanSong"{
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
    }
    
    func playAlienCollisionSound(){
        if self.songGenre == "DefaultDuncanSong" {
        let randomNum = CGFloat.random(min: 1, max: 2)
        if randomNum <= 1 {
            SKTAudio.sharedInstance().playSoundEffect("rerrr.wav")
        }else{
            SKTAudio.sharedInstance().playSoundEffect("blop_seven.wav")
        }
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
                SKAction.waitForDuration(0.7)])))
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
                SKAction.waitForDuration(10)])))
        println("Dragon on scene on now")
    }
    
    //MARK: start acceleromiter updates
    

    func nSTimeIntervalValueToString(nSTimeIntervalValue: NSTimeInterval, decimalPlaceRequired: Int) -> String {
        
        //create the number formatter and remove all decimal places
        let nf = NSNumberFormatter()
        nf.numberStyle = .DecimalStyle
        nf.maximumFractionDigits = decimalPlaceRequired
        
        return nf.stringFromNumber(nSTimeIntervalValue)!
    
    }


    
    

}
