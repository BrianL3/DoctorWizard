//
//  AnimationController.swift
//  DoctorWizard
//
//  Created by GTPWTW on 1/27/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import UIKit

class AnimationController {
    
    //singleton
    class var singleton: AnimationController {
        struct Static {
            static let instance : AnimationController = AnimationController()
        }
        return Static.instance
    }
    
    
    //MARK: SIMPLE FADE IN AND SCALE ======================================================
    
    func simpleFadeInScale(vc: UIViewController) {
        
        //do animation
        vc.view.alpha = 0
        
        //do trasform
        vc.view.transform = CGAffineTransformMakeScale(1.2, 1.2)
        
        //do animation
        UIView.animateWithDuration(0.2, delay: 0.5, options: nil, animations: { () -> Void in
            
            vc.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            vc.view.alpha = 1
            
            }) { (finished) -> Void in
                
        }
        
    }
}