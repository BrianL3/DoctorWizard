//
//  Dude.swift
//  DoctorWizard
//
//  Created by drwizzard on 2/9/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import Foundation
import SpriteKit

class Dude {
    var healthPoints:Int = 742
    var sprite:SKSpriteNode = SKSpriteNode(imageNamed: "dude0")
    var direction:String = "right"
    let dudeAnimationRight:SKAction
    let dudeAnimationLeft:SKAction
    var isInvincible:Bool = false
    
    init() {
        var texturesRight: [SKTexture] = []
        var texturesLeft: [SKTexture] = []
        for i in 0...10 {
            texturesRight.append(SKTexture(imageNamed: "dude\(i)" ))
            texturesLeft.append(SKTexture(imageNamed: "dudeLeft\(i)"))
        }
        self.dudeAnimationRight = SKAction.repeatActionForever(SKAction.animateWithTextures(texturesRight, timePerFrame: 0.1))
        self.dudeAnimationLeft = SKAction.repeatActionForever(SKAction.animateWithTextures(texturesLeft, timePerFrame: 0.1))
    }
    
}