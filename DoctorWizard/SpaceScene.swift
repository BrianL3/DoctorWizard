//
//  SpaceScene.swift
//  DoctorWizard
//
//  Created by drwizzard on 2/9/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion

protocol MainMenuDelegate {

    func restartWithSameSong(usingDefaultSong: Bool)
    func restartWithDifferentSong()
}

class SpaceScene: SKScene, SKPhysicsContactDelegate {
    
    
    var timeController = GameTime.sharedTameControler;
    
    
    //MARK: setup time propertys
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
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
    let backgroundLayer:BackgroundLayer = BackgroundLayer(backgroundImageName: "background0", backgroundIdentifier: "background", movePointsPerSec: 60)
    var backgroundDirection = CGPoint(x: 1.0 , y: 1.0)
    
    let starLayer:BackgroundLayer = BackgroundLayer(backgroundImageName: "starsFinal", backgroundIdentifier: "stars", movePointsPerSec: 100)
    
    //setup dude and dudes enemies
    let dude:Player = Player()
    var colisionBitMaskDude :UInt32 = 0x1
    var colisionBitMaskRock :UInt32 = 0x10

    //set up for game console labels
    var galacticFont = "GALACTIC_VANGUARDIAN_NCV"
    var playTimeRemainingLabel : SKLabelNode?
    var playTimeRemainingTicker: NSTimeInterval = 0
    var doctorWizardsHealthLabel : SKLabelNode?
    
    var healthPoints :CGFloat = 742 //need colisions to decrement from this
    
    //set up win-loss condition
    // false means lose, true means win
    var winCondition: Bool?
    
    //our current level
    var curLevel : Level = .First
    
    
    override init(size: CGSize) {
        self.playableRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.centerScreen = CGPoint(x: playableRect.width/2, y: playableRect.height/2)
       
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
        addChild(starLayer)
        
        //MARK: Area to spawn enemies based on song time interval ================================
        //self.spawnPinkRock()
        //self.spawnBlackHole()
        //self.spawnDragon()
        //self.spawnAlien()
        self.spawnFireBall()
        
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
        playTimeRemainingLabel?.position = CGPoint(x: self.view!.frame.width*0.2, y: self.view!.frame.height*0.8);
        playTimeRemainingLabel?.zPosition = 20
        self.addChild(playTimeRemainingLabel!)
        

        doctorWizardsHealthLabel = SKLabelNode(fontNamed:"GALACTICVANGUARDIANNCV")
        doctorWizardsHealthLabel?.fontColor = SKColor.redColor()
        doctorWizardsHealthLabel?.fontSize = 45;
        doctorWizardsHealthLabel?.position = CGPoint(x: 1700, y: 350)
        doctorWizardsHealthLabel?.position = CGPoint(x: self.view!.frame.width*2.8, y: self.view!.frame.height*0.8);
        doctorWizardsHealthLabel?.zPosition = 16
        self.addChild(doctorWizardsHealthLabel!)
        
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    }
    
    
    override func update(currentTime: NSTimeInterval) {

        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        println("I'm updating")
        println(self.dude.position.x)
        
        
        if UIApplication.sharedApplication().applicationState != UIApplicationState.Background && UIApplication.sharedApplication().applicationState != UIApplicationState.Inactive{

            self.timeController.ellapsedTime += 0.01
            println(self.timeController.ellapsedTime)
        }
        self.curLevel = currentLevelIs()
       // spawnCurrentEnemies()

        starLayer.moveBackground(currentScene: self, direction: self.backgroundDirection, deltaTime: self.dt)
        backgroundLayer.moveBackground(currentScene: self, direction: self.backgroundDirection, deltaTime: self.dt)
    
        
        //MARK: GAME CONSOLEr
        //~~~Time to Play Ticker~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        
        playTimeRemainingTicker = songDuration - self.timeController.ellapsedTime*10
        
            if ( playTimeRemainingTicker > 0 ){
                playTimeRemainingLabel?.text = "\(nSTimeIntervalValueToString(playTimeRemainingTicker,decimalPlaceRequired: 0))"
                    if ( playTimeRemainingTicker > 15 ){
                        playTimeRemainingLabel?.fontColor = SKColor.yellowColor()
                    }else{
                        playTimeRemainingLabel?.fontColor = SKColor.redColor()
                    }
            }else{
                playTimeRemainingLabel?.text = "\(0)"
            }
        
        //~~~Health Points~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
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

        
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    
    }
    
//MARK: DID EVALUATE ACTIONS
    override func didEvaluateActions() {

        if let didWin = self.winCondition {
            if didWin == true{
                self.scene?.paused = true
                let winGameScene = WinScene(size: self.size)
                winGameScene.mainMenuDelegate = self.menuDelegate
                if self.songGenre == "DefaultDuncanSong"{
                    winGameScene.isDefaultSong = true
                }
                
                self.view?.presentScene(winGameScene)

            }else if didWin == false {
                self.scene?.paused = true
                let lostGameScene = LooserScene(size: self.size)
                lostGameScene.mainMenuDelegate = self.menuDelegate
                if self.songGenre == "DefaultDuncanSong"{
                    lostGameScene.isDefaultSong = true
                }
                
                self.view?.presentScene(lostGameScene)
            }
        }
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody :SKPhysicsBody!
        var secondBody :SKPhysicsBody!
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        switch firstBody.collisionBitMask {
        case colisionBitMaskDude:
            println("firstBody is dude")
        default:
            secondBody.velocity = CGVectorMake(-self.backgroundLayer.horizontalDirection * 100, -self.backgroundLayer.verticalDirection * 100)
            println("firstBody is rock")
        }
 
    }
    
    func spawnFireBall() {
        let spawnFireBallAction = SKAction.runBlock{ () -> Void in
            let fireBall = FireBall(fireBallImageName: "fireball", initialPosition: self.fireBallSpawnPoint())
            self.backgroundLayer.addChild(fireBall)
            fireBall.spawnFireBall(self.backgroundLayer)
        }
        self.backgroundLayer.runAction(SKAction.repeatActionForever( SKAction.sequence([spawnFireBallAction, SKAction.waitForDuration(0.5)])))
        println("Spawning FireBall")
    }
    

    
    func spawnAlien() {
        let spawnAlien = SKAction.runBlock { () -> Void in
            let alien = Alien(alienImageName: "Spaceship", initialPosition: self.pinkRockSpawnPoint()) //use same spawn code as rocks
            self.backgroundLayer.addChild(alien);
            alien.spawnAlien(self.backgroundLayer, dudePosition: self.centerScreen);
        }
        
        let spawnAction = SKAction.repeatActionForever((SKAction.sequence([spawnAlien, SKAction.waitForDuration(1)])))
        self.backgroundLayer.runAction(spawnAction)

    }
    
    func spawnBlackHole() {
        let spawnBlackHoleAction = SKAction.runBlock{ () -> Void in
            let blackHole = BlackHole(blacHoleImageName: "blackhole", initialPosition: self.pinkRockSpawnPoint()) //use same spawn code as rocks
            self.backgroundLayer.addChild(blackHole)
            blackHole.spawnBlackHole()
        }
        self.backgroundLayer.runAction(SKAction.repeatActionForever( SKAction.sequence([spawnBlackHoleAction, SKAction.waitForDuration(10)])))
        println("Spawning Black Hole")
    }
    
    func spawnDragon() {
        let spawnDragonAction = SKAction.runBlock{ () -> Void in
            let dragon = Dragon(dragonImageName: "dragon2", initialPosition: self.fireBallSpawnPoint()) 
            self.backgroundLayer.addChild(dragon)
            dragon.spawnDragon(self.backgroundLayer)
        }
        self.backgroundLayer.runAction(SKAction.repeatActionForever( SKAction.sequence([spawnDragonAction, SKAction.waitForDuration(0.5)])))
        println("Spawning Dragon")
}
    
    
    
    func spawnPinkRock(){
        let spawnRockAction = SKAction.runBlock { () -> Void in
            if UIApplication.sharedApplication().applicationState != UIApplicationState.Background{
                let rock = PinkRock(rockImageName: "pinkRock1", initialPosition: self.pinkRockSpawnPoint())
                self.backgroundLayer.addChild(rock)
                rock.fadeInFadeOut()
            }
            
        }
        self.backgroundLayer.runAction(SKAction.repeatActionForever( SKAction.sequence([spawnRockAction, SKAction.waitForDuration(0.7)])))
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
    
    func currentLevelIs() -> Level {
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

    
}