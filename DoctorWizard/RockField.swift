//
//  RockField.swift
//  DoctorWizard
//
//  Created by drwizzard on 2/9/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import Foundation

import Foundation
import SpriteKit

class Rocks {
    var rockNames :[String] = []
    var backgroundLayer:BackgroundLayer
    var scene:SKScene
    
    init (backgroundLayer:BackgroundLayer, scene:SKScene) {
        for i in 1...5 {
            rockNames.append("pinkRock\(i)")
        }
        self.backgroundLayer = backgroundLayer
        self.scene = scene
        
        
    }
    
    func newRock(){
        var rock = Rock(rockImageName: rockNames[0], initialPosition: randomSpawnPoint(), backgroundLayer: self.backgroundLayer, currentScene: self.scene)

    }
    
    func spawnRocks(){
        self.backgroundLayer.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(newRock), SKAction.waitForDuration(0.7)])))
    }

    
    func randomSpawnPoint() -> CGPoint {
        let posX : CGFloat = CGFloat.random(min: 0, max: 4096) - 1024
        let posY : CGFloat = CGFloat.random(min: 0, max: 3072) - 767
        let position = CGPoint(x: posX, y: posY)
        return position
    }
    
    //test
}