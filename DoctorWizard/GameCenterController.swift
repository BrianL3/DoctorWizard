//
//  GameCenterController.swift
//  DoctorWizard
//
//  Created by GTPWTW on 1/29/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import UIKit
import GameKit
import SpriteKit

class GameCenterController {
    
    //singleton
    class var singleton: GameCenterController {
        struct Static {
            static let instance : GameCenterController = GameCenterController()
        }
        return Static.instance
    }
    
    var leaderboardIdentifier = String()
    var gameCenterEnabled = Bool()
    
    //authenticate user
    func authenticateLocalPlayer(vc: UIViewController) {
        
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController: UIViewController?, error: NSError?) -> Void in
            if viewController != nil {
                vc.presentViewController(viewController!, animated: true, completion: nil)
            } else {
                
                if localPlayer.authenticated {
                    self.gameCenterEnabled = true
                    
                    localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier, error) -> Void in
                        if error != nil {
                            println("\(error.description)")
                        } else {
                            self.leaderboardIdentifier = leaderboardIdentifier
                        }
                    })
                }
                else {
                    self.gameCenterEnabled = false
                }
            }
        }
    }
    
    
    //report score
    func reportScore(intForScore: Int64, forLeaderboard: String) {
        var score = GKScore(leaderboardIdentifier: forLeaderboard)
        score.value = intForScore
        
        GKScore.reportScores([score], withCompletionHandler: { (error) -> Void in
            if error != nil {
                println(error.description)
            }
        })
    }
    



    
}