//
//  Dragon.swift
//  DoctorWizard
//
//  Created by Rodrigo Carballo on 1/29/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import SpriteKit

class Dragon : SKSpriteNode {
    
    override init() {
        let texture = SKTexture(imageNamed: "dragon")
        super.init(texture: texture, color: nil, size: texture.size())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    }
