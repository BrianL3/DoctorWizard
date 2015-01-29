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
    
    
    //MARK: ANIMATE VIEW CONTROLLER FUNCTIONS ======================================================
    
    //MARK:  VIEW CONTROLLER BOUNCES INTO MAIN VIEW
    
    func bounceInViewController(vc: UIViewController) {
        
        
        vc.view.alpha = 0
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        
        //do trasform
        vc.view.transform = CGAffineTransformMakeScale(0.85, 0.85)
        UIView.animateWithDuration(0.2, delay: 0.5, options: nil, animations: { () -> Void in
            
            vc.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.85)
            vc.view.alpha = 1
            
            }) { (finished) -> Void in
                
        }
        
    }
    
    
    //MARK: VIEW CONTROLLER SLIDES INTO MAIN VIEW
    
    func slideOnViewController(vc: UIViewController) {
        
        vc.view.alpha = 1
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        
        let slideOnViewController = CGAffineTransformMakeTranslation(0,0)
        
        
        UIView.animateWithDuration(0.4, delay: 0.2, options: nil, animations: { () -> Void in

            vc.view.transform = slideOnViewController
            vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.85)
            
            }) { (finished) -> Void in
                
        }
        
    }
    
    //MARK: VIEW CONTROLLER SLIDES OFF MAIN VIEW
    
    func slideOffViewController(vc: UIViewController) {
       
        vc.view.alpha = 1
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.85)
        
        let slideOffViewController = CGAffineTransformMakeTranslation(-800,0)
        

        UIView.animateWithDuration(0.4 , delay: 0.1, options: nil, animations: { () -> Void in
            
            vc.view.transform = slideOffViewController
            vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
            
            }) { (finished) -> Void in
                
        }
        
    }
    
    
}