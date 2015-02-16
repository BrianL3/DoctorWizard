//
//  GameTime.swift
//  DoctorWizard
//
//  Created by drwizzard on 2/15/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import Foundation

class GameTime {
    
    class var sharedTameControler : GameTime {
        struct Static {
            static let instance: GameTime = GameTime()
        }
        return Static.instance
    }
    
    var ellapsedTime: NSTimeInterval = 0
    var currentTime: NSTimeInterval = 0
    var pausedTime: NSTimeInterval = 0
    var startTime: NSTimeInterval = 0
    
    
    
    
    
}