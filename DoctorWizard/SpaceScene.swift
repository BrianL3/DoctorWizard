//
//  SpaceScene.swift
//  DoctorWizard
//
//  Created by drwizzard on 2/9/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion
import GameKit

protocol MainMenuDelegate {

    func restartWithSameSong(usingDefaultSong: Bool)
    func restartWithDifferentSong()
}

class SpaceScene: SKScene, SKPhysicsContactDelegate {
    
    
    var timeController = GameTime.sharedTameControler;
    
    
    //MARK: setup time propertys
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    var updateCounterForSpawing: Int = 0
    
    //setup songduration things
    var songDuration : NSTimeInterval!
    var songGenre : String!

    //menu delegate
    var menuDelegate: MainMenuDelegate?
    
    //setup screen frame propertys
    let playableRect:CGRect
    let centerScreen:CGPoint
    
    // setup controlls
    let motionManager = CMMotionManager()
    
    //setup layers
    let backgroundLayer:BackgroundLayer = BackgroundLayer(backgroundImageName: "background0", backgroundIdentifier: "background", movePointsPerSec: 7)
    var backgroundDirection = CGPoint(x: 1.0 , y: 1.0)
    
    let starLayer:BackgroundLayer = BackgroundLayer(backgroundImageName: "starsFinal", backgroundIdentifier: "stars", movePointsPerSec: 15)
    
    let debriLayer = BackgroundLayer(backgroundImageName: "dunk_debri", backgroundIdentifier: "debri", movePointsPerSec: 20)
    
    let bigDebriLayer = BackgroundLayer(backgroundImageName: "debri_big3", backgroundIdentifier: "big_debri", movePointsPerSec: 20)
    
    //setup dude and dudes enemies
    let dude:Player = Player()
    var colisionBitMaskDude :UInt32 = 0x1
    var colisionBitMaskRock :UInt32 = 0x10
    
    //touch location
    var lastTouchLocation :CGPoint?
    
    //setup dragon
    var dragon: Dragon?
    

    //set up for game console labels
    var galacticFont = "GALACTIC_VANGUARDIAN_NCV"
    var playTimeRemainingLabel : SKLabelNode?
    var playTimeRemainingTicker: NSTimeInterval = 0
    var doctorWizardsHealthLabel : SKLabelNode?
    

    var dudeSetInvincibleCount:Int = 0

    //set up win-loss condition
    // false means lose, true means win
    var winCondition: Bool?
    var isPresenting = false
    
    //our current level
    var curLevel : Level = .First
    
    //Physics Category bitmask
    let categoryDude:UInt32 =      0x1
    let categoryPinkROck:UInt32 =  0x10
    let categoryFireball:UInt32 =  0x100
    let categoryAlien:UInt32 =     0x1000
    let categoryBlackHole:UInt32 = 0x10000
    let categoryDragon:UInt32 =    0x100000


    override init(size: CGSize) {
        self.playableRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.centerScreen = CGPoint(x: playableRect.width/2, y: playableRect.height/2)
       
        let screenSize :CGRect = UIScreen.mainScreen().bounds
        
        
        super.init(size: size)
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    
    override func didMoveToView(view: SKView) {
        dude.position = centerScreen
        
        addChild(backgroundLayer)
        self.addChild(self.dude)
        self.dude.position = self.centerScreen
        self.dude.zPosition = 4
        addChild(starLayer)
        addChild(debriLayer)
        addChild(bigDebriLayer)
        
        //MARK: Area to spawn enemies based on song time interval ================================
        //self.spawnPinkRock()
        //self.spawnBlackHole()
        //self.spawnDragon()


        
//        self.runAction(SKAction.repeatActionForever( SKAction.sequence([SKAction.waitForDuration(1), SKAction.runBlock({ () -> Void in
//            if self.paused == false {
//                self.ellapsedTime += 1
//                println(self.ellapsedTime)
//            }
//        })])))
        
        if motionManager.accelerometerAvailable {
            self.motionManager.accelerometerUpdateInterval = 0.1
            self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) -> Void in
                if error == nil {
                    let verticalData = data.acceleration.x
                    let horizontalData = data.acceleration.y
                    self.backgroundDirection.y = CGFloat(verticalData * 50.0)
                    self.backgroundDirection.x = CGFloat(horizontalData * 50.0)
                    self.dude.animateDude(self.backgroundDirection)

                    //  println("we got acceleromiter data : \(verticleData)")
                }
            })
        }
        
        //Adding Game Console Labels~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Labels positions need to be dynamically set
        
        playTimeRemainingLabel = SKLabelNode(fontNamed:"GALACTICVANGUARDIANNCV")
        playTimeRemainingLabel!.fontSize = 100;
//        playTimeRemainingLabel?.position = CGPoint(x: self.view!.frame.width*0.2, y: self.view!.frame.height*0.8);
        
        let screenSize :CGRect = UIScreen.mainScreen().bounds
        let xScalar = screenSize.width/self.playableRect.width
        let yScalar = screenSize.height/self.playableRect.height
        
        playTimeRemainingLabel?.position = CGPoint(x: self.centerScreen.x - self.playableRect.width*xScalar*0.95, y: self.centerScreen.y - self.playableRect.height*yScalar*0.95);
        println("PlayTime position")
        println(playTimeRemainingLabel?.position)
        playTimeRemainingLabel?.zPosition = 20
        self.addChild(playTimeRemainingLabel!)
        

        doctorWizardsHealthLabel = SKLabelNode(fontNamed:"GALACTICVANGUARDIANNCV")
        doctorWizardsHealthLabel?.fontColor = SKColor.redColor()
        doctorWizardsHealthLabel?.fontSize = 100;

        doctorWizardsHealthLabel?.position = CGPoint(x: self.centerScreen.x + self.playableRect.width*xScalar*0.95, y: self.centerScreen.y - self.playableRect.height*yScalar*0.95);
        println("Wizard Health position")
        println(doctorWizardsHealthLabel?.position)
        doctorWizardsHealthLabel?.zPosition = 16
        self.addChild(doctorWizardsHealthLabel!)
        
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    }
    
    
    override func update(currentTime: NSTimeInterval) {
        self.updateCounterForSpawing += 1
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
            if UIApplication.sharedApplication().applicationState != UIApplicationState.Background && UIApplication.sharedApplication().applicationState != UIApplicationState.Inactive && !self.paused{
                
                self.timeController.ellapsedTime += dt
            }
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
//        println("I'm updating")
//        println(self.dude.position.x)
        
        
        if self.dude.isInvincible == true {
            if self.updateCounterForSpawing -  self.dudeSetInvincibleCount > Int(60 * 1.5) {
                self.dude.isInvincible = false
                println("we have set  the dude invincible to false")
            }
        }
        


//        self.curLevel = currentLevelIs()
        self.currentLevel()
       // spawnCurrentEnemies()

        starLayer.moveBackground(currentScene: self, direction: self.backgroundDirection, deltaTime: self.dt)
        backgroundLayer.moveBackground(currentScene: self, direction: self.backgroundDirection, deltaTime: self.dt)
        debriLayer.moveBackground(currentScene: self, direction: self.backgroundDirection, deltaTime: self.dt)
        bigDebriLayer.moveBackground(currentScene: self, direction: self.backgroundDirection, deltaTime: self.dt)
    
        
        //MARK: GAME CONSOLEr
        //~~~Time to Play Ticker~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        
        playTimeRemainingTicker = songDuration - (self.timeController.ellapsedTime)
        
            if ( playTimeRemainingTicker > 0 ){
                playTimeRemainingLabel?.text = "\(nSTimeIntervalValueToString(playTimeRemainingTicker, decimalPlaceRequired: 0))"
                    if ( playTimeRemainingTicker > 15 ){
                        playTimeRemainingLabel?.fontColor = SKColor.yellowColor()
                    }else{
                        playTimeRemainingLabel?.fontColor = SKColor.redColor()
                    }
            }else{
                playTimeRemainingLabel?.text = "\(0)"
                self.winCondition = true
            }
        
        //~~~Health Points~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
                 //MARK: Display Spaceman's Health Status Label
                    let healthyIconEmoji: String = "🍏"
                    let unhealthyIconEmoji: String = "🍊"
                    let expiredEmoji: String = "😑"
        

//                        println("dudes health points = \(dude.healthPoints)");
        
//                        if (healthPoints == 0 ){
//                                //Player is spacedust
//                                doctorWizardsHealthLabel?.text = "\(expiredEmoji)"
//                        }else{
//        
//        
//                                //strongest >= 80%
//                            if (healthPoints >= fullHealthStatus*0.8 && healthPoints <= fullHealthStatus){
//                                    //println("strongest condition reached")
//                                    doctorWizardsHealthLabel?.text = "\(healthyIconEmoji)\(healthyIconEmoji)\(healthyIconEmoji)\(healthyIconEmoji)\(healthyIconEmoji)"
//                            }
//        
//                                //strong <= 80% && >=60%
//                            if(healthPoints <= fullHealthStatus*0.8 && healthPoints >= fullHealthStatus*0.6){
//                                    //println("strong condition reached")
//                                    doctorWizardsHealthLabel?.text = "\(healthyIconEmoji)\(healthyIconEmoji)\(healthyIconEmoji) \(healthyIconEmoji)"
//                            }
//        
//                                //ok <= 60% && >=40%
//                            if(healthPoints <= fullHealthStatus*0.6 && healthPoints >= fullHealthStatus*0.4){
//                                    //println("ok condition reached")
//                                    doctorWizardsHealthLabel?.text = "\(healthyIconEmoji)\(healthyIconEmoji)\(healthyIconEmoji)"
//                            }
//        
//                                //weak <= 40% && >=20%
//                            if(healthPoints <= fullHealthStatus*0.4 && healthPoints >= fullHealthStatus*0.2){
//                                    //println("weak condition reached")
//                                    doctorWizardsHealthLabel?.text = "\(unhealthyIconEmoji)\(unhealthyIconEmoji)"
//                            }
//                
//                                //weakest <= 20%
//                                if(healthPoints <= fullHealthStatus*0.2){
//                                    //println("weakest condition reached")
//                                    doctorWizardsHealthLabel?.text = "\(unhealthyIconEmoji)"
//                                }
//                
//                            }
//
            self.doctorWizardsHealthLabel?.text = "\(self.dude.healthPoints)"
        
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
        moveDude()
    }
    
//MARK: DID EVALUATE ACTIONS (occurs every frame) =========================================
    override func didEvaluateActions() {
//        self.spawnFireBall()
//        self.spawnPinkRock()
//        self.spawnAlien()
//        self.spawnBlackHole()
//        self.spawnDragon()
        
        if self.dude.hitByBlackHole == true {
            self.dude.healthPoints -= 3
        }
        
        if self.dude.healthPoints <= 0 {
            self.winCondition = false
        }
        

        
        if let didWin = self.winCondition{
            if self.isPresenting == false {
                println("entered win condition loop because winCondition was set as true or false")
                // player won
                if didWin == true{
                    
                    self.paused = true
                    if GameCenterKit.sharedGameCenter.gameCenterEnabled == true{
                        // create achievements, if any
                        var achievementsArray = [GKAchievement]()
                        achievementsArray.append(GameCenterKit.sharedGameCenter.achievementHelper.minuteAchievement(timeController.ellapsedTime))
                        // send achievements to gamecenter
                        GameCenterKit.sharedGameCenter.reportAchievements(achievementsArray)
                        // log the time as a score, rounded to an int
                        let scoreDouble = self.timeController.ellapsedTime as Double
                        let score : Int64 = Int64(round(scoreDouble))
                        GameCenterKit.sharedGameCenter.reportScore(score, forLeaderBoardId: "games.doctorwizard.longest_song")
                    }
                    
                    let winGameScene = WinScene(size: self.size)
                    winGameScene.mainMenuDelegate = self.menuDelegate
                    if self.songGenre == "DefaultDuncanSong"{
                        SKTAudio.sharedInstance().pauseBackgroundMusic()
                        winGameScene.isDefaultSong = true
                    }
                    GameTime.sharedTameControler.ellapsedTime = 0.0
                    let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                    view?.presentScene(winGameScene, transition: reveal)
                    self.isPresenting = true  // setting a flag: without this flag didEvaluateActions calls Present many times and bugs out
                    //player lost
                    
                }else if didWin == false {
                    self.paused = true
                    let lostGameScene = LooserScene(size: self.size)
                    lostGameScene.mainMenuDelegate = self.menuDelegate
                    if self.songGenre == "DefaultDuncanSong"{
                        lostGameScene.isDefaultSong = true
                    }
                    GameTime.sharedTameControler.ellapsedTime = 0.0
                    let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                    view?.presentScene(lostGameScene, transition: reveal)
                    self.isPresenting = true  // setting a flag: without this flag didEvaluateActions calls Present many times and bugs out
                }  //eo win or lose check
            }  //eo special flag check
        }  
    }
    
    //MARK: CONTACT BETWEEN PHYSICS BODIES
    func didBeginContact(contact: SKPhysicsContact) {
        var dudeBody :SKPhysicsBody?
        var otherBody :SKPhysicsBody?
        if contact.bodyA.categoryBitMask == self.categoryDude {
            dudeBody = contact.bodyA
            otherBody = contact.bodyB
        } else if contact.bodyB.categoryBitMask == self.categoryDude {
            dudeBody = contact.bodyB
            otherBody = contact.bodyA
        } else {
            dudeBody = nil
            otherBody = nil
        }
    
/*
        SKAction *pulseRed = [self colorizeChoosenSpriteNodeWithColor:[SKColor redColor]];
        [_easyImage runAction: pulseRed];
*/

        if (dudeBody != nil && self.dude.isInvincible != true) || self.dude.hitByBlackHole{
            println("dude is one of the contact bodys")
            self.dude.setInvincible()
            self.dudeSetInvincibleCount = self.updateCounterForSpawing
            
            switch otherBody!.categoryBitMask {
            case self.categoryPinkROck :
                self.dude.healthPoints -= 30
                otherBody!.velocity = CGVectorMake(-self.backgroundLayer.horizontalDirection * 90, -self.backgroundLayer.verticalDirection * 90)
            case self.categoryFireball :
                self.dude.healthPoints -= 100
            case self.categoryAlien :
                self.dude.healthPoints -= 150
                println("dude hit alien")
            case self.categoryBlackHole :
//                self.dude.healthPoints -= 2
                self.dude.hitByBlackHole = true
                self.backgroundLayer.enumerateChildNodesWithName("blackhole", usingBlock: { (node, _) -> Void in
                    
                    let blackWhole = node as SKSpriteNode

                    let dudePositionOnBG = self.backgroundLayer.convertPoint(self.dude.position, fromNode: self)
                    let dudeFrameOnBG = CGRect(origin: dudePositionOnBG, size: self.dude.size)
                    println("we found the blackwhole \(blackWhole.frame)")
                    println("dude position is         \(dudeFrameOnBG)")
                    if CGRectIntersectsRect(blackWhole.frame, dudeFrameOnBG){
                        println("what is up we hit the blackWhole")
                        let angle : CGFloat = -CGFloat(M_PI)
                        let oneSpin = SKAction.rotateByAngle(angle, duration: 0.5)
//                        let repeatSpin = SKAction.repeatActionForever(oneSpin)
                        let repeatSpin = SKAction.repeatActionForever(oneSpin)
                        let implode = SKAction.scaleTo(0, duration: 2.0)
                        let moveDudeToPoint = self.convertPoint(blackWhole.position, fromNode: self.backgroundLayer)
                        let moveAction = SKAction.moveTo(moveDudeToPoint, duration: 2)
                        let actionRemove = SKAction.removeFromParent()
                        let groupDeathAction = SKAction.group([repeatSpin,moveAction,implode])
                        let seq = SKAction.sequence([groupDeathAction, actionRemove])
                        self.dude.runAction(seq)
                    }
                })
            case self.categoryDragon:
                println("yaawww the dude hit the dragon")
                self.dude.healthPoints -= 200
            default:
                println("")

                }
            self.dude.runAction(dude.flashDude())

        } else if (dudeBody != nil ) && (otherBody!.categoryBitMask == self.categoryPinkROck) {
            otherBody!.velocity = CGVectorMake(-self.backgroundLayer.horizontalDirection * 90, -self.backgroundLayer.verticalDirection * 90)
        }
        

            
    }
    
//    func destroyByBlackHole {
//
//            
//            let angle : CGFloat = -CGFloat(M_PI)
//            let oneSpin = SKAction.rotateByAngle(angle, duration: 3.5)
//            let repeatSpin = SKAction.repeatActionForever(oneSpin)
//            let implode = SKAction.scaleTo(0, duration: 2.0)
//            let actionRemove = SKAction.removeFromParent()
//            let actionTowardsBlackHoleXCoord = SKAction.moveToX(self.blackHole.position.x, duration: 1.0)
//            self.dude.runAction(actionTowardsBlackHoleXCoord)
//            let actionTowardsBlackHoleYCoord = SKAction.moveToY(self.blackHole.position.y, duration: 1.0)
//            self.dude.runAction(actionTowardsBlackHoleYCoord)
//            let actions = [implode, actionRemove]
//            dudeHit.runAction(repeatSpin)
//            dudeHit.runAction(SKAction.sequence(actions), completion: { () -> Void in
//                if self.invincible == false {
//                    self.healthPoints = 0
//                }
//            })
//        }
//    }

    
    
    
//        switch contact.bodyA.categoryBitMask {
//        case self.categoryFireball:
//            if
//        default:
////            secondBody.velocity = CGVectorMake(-self.backgroundLayer.horizontalDirection * 100, -self.backgroundLayer.verticalDirection * 100)
//            println("firstBody is rock")
//        }
 
    
    
    func spawnFireBall() {

        if self.updateCounterForSpawing % Int(2.5 * 60) == 0 {
            let fireBall = FireBall(fireBallImageName: "fireball", initialPosition: self.fireBallSpawnPoint())
            self.backgroundLayer.addChild(fireBall)
            fireBall.spawnFireBall(self.backgroundLayer)
                    println("Spawning FireBall")
        }


    }
    

    
    func spawnAlien() {

        if self.updateCounterForSpawing % Int(60 * 1.5) == 0 {

            let topRight = CGPoint(x: 2048 + 100, y: 1536 + 100)
            let bottomRight = CGPoint(x: 2048 + 100, y: 0 - 100)
            let topLeft = CGPoint(x: 0  - 100, y: 1536 + 100)
            let bottomLeft = CGPoint(x: 0 - 100, y: 0 - 100)
            let cornerPointArray = [topLeft, topRight, bottomRight, bottomLeft]
            
            var random = Int((CGFloat.random()*4))
            if random == 4 {
                random = 3 //covernin my ass 
                // #yolo
            }
            
            let initPosition = self.backgroundLayer.convertPoint(cornerPointArray[random], fromNode: self)
            let destPosition = self.backgroundLayer.convertPoint(cornerPointArray[(random + 2) % 4], fromNode: self)
            let alien = Alien(alienImageName: "Spaceship", initialPosition: initPosition)
            self.backgroundLayer.addChild(alien)
            alien.spawnAlien(destPosition)
        }

    }
    
    func spawnBlackHole() {
//        let spawnBlackHoleAction = SKAction.runBlock{ () -> Void in
//            let blackHole = BlackHole(blacHoleImageName: "blackhole", initialPosition: self.pinkRockSpawnPoint()) //use same spawn code as rocks
//            self.backgroundLayer.addChild(blackHole)
//            blackHole.spawnBlackHole()
//        }
//        self.backgroundLayer.runAction(SKAction.repeatActionForever( SKAction.sequence([spawnBlackHoleAction, SKAction.waitForDuration(10)])))
//        println("Spawning Black Hole")

        if self.updateCounterForSpawing % Int(60 * 7) == 0 {
////            let rock = PinkRock(rockImageName: "pinkRock1", initialPosition: self.pinkRockSpawnPoint())
////            self.backgroundLayer.addChild(rock)
////            rock.fadeInFadeOut()
            println("bout to spawn a balckwhole")
        let blackHole = BlackHole(blacHoleImageName: "blackhole", initialPosition: self.pinkRockSpawnPoint()) //use same spawn code as rocks
        self.backgroundLayer.addChild(blackHole)
        blackHole.spawnBlackHole()
            println("black whole has spawned")
//
        }
    }
    
    func spawnDragon() {
        if self.dragon == nil {
            println("fuccck in der is a dragon")
            let spawnPoint = CGPoint(x: self.size.width * 0.8, y: self.size.height * 0.8)
            let bgSpawnPoint = self.backgroundLayer.convertPoint(spawnPoint, fromNode: self)
            self.dragon = Dragon(dragonImageName: "dragon2", initialPosition: bgSpawnPoint)
            self.backgroundLayer.addChild(self.dragon!)
        } else if self.updateCounterForSpawing % Int(1.5 * 60) == 0 {
            let moveToPoint = self.backgroundLayer.convertPoint(dragonMoveToRandomPoint(), fromNode: self)
            self.dragon?.moveDragonTo(moveToPoint)
        }
        
        
//        let spawnDragonAction = SKAction.runBlock{ () -> Void in
//            let dragon = Dragon(dragonImageName: "dragon2", initialPosition: self.fireBallSpawnPoint()) 
//            self.backgroundLayer.addChild(dragon)
//            dragon.spawnDragon(self.backgroundLayer)
//        }
//        self.backgroundLayer.runAction(SKAction.repeatActionForever( SKAction.sequence([spawnDragonAction, SKAction.waitForDuration(0.5)])))
//        println("Spawning Dragon")
    }
    
    
    //dont call this function unless the dragon exisits
    func dragonMoveToRandomPoint() -> CGPoint {
        let dragonWidth = self.dragon!.size.width
        let dragonHeigh = self.dragon!.size.height
        let posX : CGFloat = CGFloat.random(min: dragonWidth, max: self.size.width - dragonWidth)
        let posY : CGFloat = CGFloat.random(min: dragonHeigh, max: self.size.height - dragonHeigh)
        return CGPoint(x: posX, y: posY)
    }
    
    
    
    func spawnPinkRock(){

        
        let randomRockString = "pinkRock\((arc4random()%5) + 1)"
        
        if self.updateCounterForSpawing % Int(60 * 1.2) == 0 {
            let rock = PinkRock(rockImageName: randomRockString, initialPosition: self.pinkRockSpawnPoint())
            self.backgroundLayer.addChild(rock)
//            rock.fadeInFadeOut()
            rock.spawnRock()
        }
        
    }
    
    
    func pinkRockSpawnPoint() -> CGPoint {
        let posX : CGFloat = CGFloat.random(min: 0, max: 4096) - 1024
        let posY : CGFloat = CGFloat.random(min: 0, max: 3072) - 767
        let positionToConvert = CGPoint(x: posX, y: posY)
        let position = self.backgroundLayer.convertPoint(positionToConvert, fromNode: self)
        return position
    }
    
    func fireBallSpawnPoint() -> CGPoint {
        let posX : CGFloat = 3072

        let posY : CGFloat = CGFloat.random(min: 0, max: 3072) - 767
        let positionToConvert = CGPoint(x: posX, y: posY)
        let position = self.backgroundLayer.convertPoint(positionToConvert, fromNode: self)
        return position
    }

    override func willMoveFromView(view: SKView) {
        self.paused = true
        println("bouta pause game")
        self.removeAllActions()

    }
    
    func nSTimeIntervalValueToString(nSTimeIntervalValue: NSTimeInterval, decimalPlaceRequired: Int) -> String {
        
        //create the number formatter and remove all decimal places
        let nf = NSNumberFormatter()
        nf.numberStyle = .DecimalStyle
        nf.maximumFractionDigits = decimalPlaceRequired
        
        return nf.stringFromNumber(nSTimeIntervalValue)!
        
    }
    
    func moveDude() {
        
        
        let amountToMove = CGPoint(x: self.dude.velocity.x * CGFloat(dt),
            y: self.dude.velocity.y * CGFloat(dt))
//        println("Amount to move: \(amountToMove)")
//        if self.dude.position == self.lastTouchLocation {
//            self.dude.position = self.lastTouchLocation!
//        } else {
        if let lastTouch = lastTouchLocation {
            
            let diff = lastTouch - dude.position
            
            if (diff.length() <= 600 * CGFloat(dt)) {
                dude.position = lastTouchLocation!
                self.dude.velocity = CGPointZero
            } else{
                
            self.dude.position = CGPoint(
                x: self.dude.position.x + amountToMove.x,
                y: self.dude.position.y + amountToMove.y)
        }
    }
    }
    
    func moveDudeToward(location: CGPoint) {
        
        let offset = location - self.dude.position
        let direction = offset.normalized()
        
        self.dude.velocity = direction * 800
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)

    }
    
    func sceneTouched(touchLocation:CGPoint) {
        
        lastTouchLocation = touchLocation
        moveDudeToward(touchLocation)
        //        println("song duration is : \(songDuration)")
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
    //MARK: Determining the current level
    enum Level {
        case First
        case Second
        case Third
        case Fourth
        case Fifth
    }
    
//    func currentLevelIs() -> Level {
//        let songTimeAsFloat = self.songDuration as Double
//        var timePassedAsFloat : Double
//        if (timeController.ellapsedTime as Double) < songTimeAsFloat{
//            timePassedAsFloat = timeController.ellapsedTime as Double
//        }else{
//            timePassedAsFloat = songTimeAsFloat
//        }
//        let twentyPercent = songTimeAsFloat/5
//        let fortyPercent = (songTimeAsFloat/5) * 2
//        let sixtyPercent = (songTimeAsFloat/5) * 3
//        let eightyPercent = (songTimeAsFloat/5) * 4
//        
//        switch timePassedAsFloat {
//            //first 20% of the song
//        case 0..<twentyPercent :
//            self.curLevel = .First
//        case twentyPercent..<fortyPercent :
//            self.curLevel = .Second
//        case fortyPercent..<sixtyPercent :
//            self.curLevel = .Third
//        case sixtyPercent..<eightyPercent :
//            self.curLevel = .Fourth
//        case eightyPercent..<songTimeAsFloat :
//            self.curLevel = .Fifth
//        default:
//            self.curLevel = .First
//        }
//        return self.curLevel
//    }

    
    func currentLevel() {
        let songTimeAsFloat = self.songDuration as Double
        var timePassedAsFloat : Double
        if (timeController.ellapsedTime as Double) < songTimeAsFloat{
            timePassedAsFloat = timeController.ellapsedTime as Double
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
            self.spawnPinkRock()
            self.spawnBlackHole()
//            println("first level")
        case twentyPercent..<fortyPercent :
            self.spawnFireBall()
            self.spawnPinkRock()

//            println("second level")
        case fortyPercent..<sixtyPercent :
            self.spawnPinkRock()
            self.spawnAlien()
//            println("third level")
        case sixtyPercent..<eightyPercent :
            self.spawnPinkRock()
            self.spawnBlackHole()
//            println("fourth level")
        case eightyPercent..<songTimeAsFloat :
            self.spawnDragon()
//            println("fith level")
        default:
            self.spawnPinkRock()
            println("default case of CurrentLevel, current level is: \(self.curLevel)")
        }
    }
    
}