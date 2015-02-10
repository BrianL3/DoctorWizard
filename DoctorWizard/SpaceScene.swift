//
//  SpaceScene.swift
//  DoctorWizard
//
//  Created by drwizzard on 2/9/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import Foundation
import SpriteKit


class SpaceScene: SKScene {
    
    let playableRect:CGRect
    let centerScreen:CGPoint
    let backgroundLayer:BackgroundLayer = BackgroundLayer(backgroundImageName: "background", backgroundIdentifier: "backgrodun", movePointsPerSec: 300)
    
    
    
    let dude:Dude = Dude()
    
    
    override init(size: CGSize) {
        self.playableRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.centerScreen = CGPoint(x: playableRect.width/2, y: playableRect.height/2)
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    
    override func didMoveToView(view: SKView) {
        dude.sprite.position = centerScreen
        
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }

    //MARK: move layers
    func moveBackground(){
        let backgroundVelocity = CGPoint(
            x: self.backgroundLayer.horizontalDirection * 60,
            y: self.backgroundLayer.verticalDirection *  60)
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
}