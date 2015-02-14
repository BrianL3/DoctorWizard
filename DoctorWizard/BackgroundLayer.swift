//
//  BackgroundLayer.swift
//  DoctorWizard
//
//  Created by drwizzard on 2/9/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import UIKit
import SpriteKit


class BackgroundLayer: SKNode {
    var verticalDirection: CGFloat = 30.0
    var horizontalDirection: CGFloat = 36.0
    var movePointsPerSec: CGFloat
    var backgroundSizeFrame = CGRect(x: 0, y: 0, width: 4096, height: 3027)
    var backgroundIdentifier:String
    
    init (backgroundImageName:String, backgroundIdentifier:String, movePointsPerSec:CGFloat) {
        self.movePointsPerSec = movePointsPerSec
        self.backgroundIdentifier = backgroundIdentifier
        super.init()
        
        for i in 0...1{
            let bottomBackground = backgroundNode(backgroundImageName)
            bottomBackground.position = CGPoint(
                x: CGFloat(i) * bottomBackground.size.width,
                y: 0)
            bottomBackground.name = backgroundIdentifier
            let topBackground = backgroundNode(backgroundImageName)
            topBackground.position = CGPoint(
                x: CGFloat(i) * bottomBackground.size.width,
                y: bottomBackground.size.height)
            topBackground.name = backgroundIdentifier
            self.addChild(bottomBackground)
            self.addChild(topBackground)

        }
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
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
    
    func updateDirection(directionAsPoint:CGPoint){
        self.horizontalDirection = directionAsPoint.x
        self.verticalDirection = directionAsPoint.y
    }
    
    func getBackgroundVelocity() -> CGPoint{
        return  CGPoint(
            x: self.horizontalDirection * self.movePointsPerSec,
            y: self.verticalDirection *  self.movePointsPerSec)
    }
    
    func moveBackground(currentScene parentView:SKScene, direction:CGPoint, deltaTime:NSTimeInterval){
        self.updateDirection(direction)
        let backgroundVelocity = self.getBackgroundVelocity()
        let ammountToMove = backgroundVelocity * CGFloat(deltaTime)
        self.position += ammountToMove
        
        self.enumerateChildNodesWithName(self.backgroundIdentifier, usingBlock: { (node, _) -> Void in
            let background = node as SKSpriteNode
            let backgroundScreenPos = self.convertPoint(background.position, toNode: parentView)
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
