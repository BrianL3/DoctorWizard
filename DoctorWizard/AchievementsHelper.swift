//
//  AchievementsHelper.swift
//  DoctorWizard
//
//  Created by Brian Ledbetter on 2/19/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import UIKit
import GameKit

class AchievementsHelper{
    struct Constants {
        static let oneminute = "gamers.doctorwizard.oneminutes"
        static let twominutes = "gamers.doctorwizard.twominutes"
        static let threeminute = "gamers.doctorwizard.threeminutes"
        static let fourminute = "gamers.doctorwizard.fourminutes"
        static let fiveminute = "gamers.doctorwizard.fiveminutes"
        static let sixminute = "gamers.doctorwizard.sixminutes"
        static let sevenminute = "gamers.doctorwizard.sevenminutes"
        static let eightminute = "gamers.doctorwizard.eightminutes"
        static let nineminute = "gamers.doctorwizard.nineminute"
        static let tenminute = "gamers.doctorwizard.oneminutes"
    }
    func minuteAchievement(timeplayed : NSTimeInterval) -> GKAchievement{
        var achievement : GKAchievement;
        
        switch timeplayed{
        case 0..<60:
            achievement = GKAchievement(identifier: Constants.oneminute)
        case 60..<120:
            achievement =  GKAchievement(identifier: Constants.twominutes)
        case 120..<180:
            achievement = GKAchievement(identifier: Constants.threeminute)
        case 180..<240:
            achievement = GKAchievement(identifier: Constants.fourminute)
        case 240..<300:
            achievement = GKAchievement(identifier: Constants.fiveminute)
        case 300..<360:
            achievement = GKAchievement(identifier: Constants.sixminute)
        case 360..<420:
            achievement = GKAchievement(identifier: Constants.sevenminute)
        case 420..<480:
            achievement = GKAchievement(identifier: Constants.eightminute)
        case 480..<540:
            achievement = GKAchievement(identifier: Constants.nineminute)
        case 540..<600:
            achievement = GKAchievement(identifier: Constants.tenminute)
        default:
            achievement = GKAchievement(identifier: Constants.tenminute)
        }
        achievement.percentComplete = 100
        achievement.showsCompletionBanner = true
        return achievement
    }

    
}