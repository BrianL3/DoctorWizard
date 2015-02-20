//
//  GameCenterKit.swift
//  DoctorWizard
//
//  Created by Brian Ledbetter on 2/19/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import GameKit
import UIKit

class GameCenterKit: NSObject {
    // game center properties
    var authenticationViewController: UIViewController?
    var lastError: NSError?
    var gameCenterEnabled: Bool
    let PresentAuthenticationViewController = "PresentAuthenticationViewController"
    let achievementHelper = AchievementsHelper()
    
    
    // gamecenter singleton
    class var sharedGameCenter : GameCenterKit {
        struct Static {
            static let instance : GameCenterKit = GameCenterKit()
        }
        return Static.instance
    }
    
    override init(){
        gameCenterEnabled = true
        super.init()
    }
//MARK: AUTHENTICATION
    func authenticateLocalPlayer(){
        let localPlayer = GKLocalPlayer.localPlayer()
    
        localPlayer.authenticateHandler = {(viewController, error) in
            self.lastError = error

            if viewController != nil {
                self.authenticationViewController = viewController
                NSNotificationCenter.defaultCenter().postNotificationName(self.PresentAuthenticationViewController, object: self)
                
            }else if localPlayer.authenticated == true { //eo: if we got a viewController back from authenticateHandler
                self.gameCenterEnabled = true
            }else{
                self.gameCenterEnabled = false
            }//eo: checking authentication
        }//eo: authenticate handler completion block
    }
//MARK: TALKING TO GAMECENTER
    func reportAchievements(achievements: [GKAchievement]){
        if gameCenterEnabled{
            GKAchievement.reportAchievements(achievements, withCompletionHandler: { (error) -> Void in
                self.lastError = error
            })
        }else{
            println("Local player is not authenticated")
            return
        }
    }
    
    func reportScore(score: Int64, forLeaderBoardId leaderBoardId: String){
        if gameCenterEnabled{
            //make a score reporter, put it in a reporting array
            let scoreReporter = GKScore(leaderboardIdentifier: leaderBoardId)
            scoreReporter.value = score
            scoreReporter.context = 0
            let scores = [scoreReporter]
            //report the array to gamecenter
            GKScore.reportScores(scores, withCompletionHandler: { (error) -> Void in
                //error reporting, if any
                self.lastError = error
                if error != nil {
                    println(error.localizedDescription)
                }
            })
        }else{
            println("Local player is not authenticated")
            return
        }
    }
}