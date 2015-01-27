//
//  PopUpMenuController.swift
//  DoctorWizard
//
//  Created by cm2y on 1/26/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import UIKit

protocol popUpMenuDelegate {

        func userDidPressSelectSong()
        func userDidPressPlayWithoutSong()
}
    

class PopUpMenuController: UIViewController {

    @IBOutlet weak var songNameLabel: UILabel!
    
    var delegate: popUpMenuDelegate?
    
    
    
    //MARK: VIEW DID LOAD ==========================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
    //MARK: IBACTIONS ==============================================================
    
    // the button labeled "Just go already" - should skip MediaPickerController and go direct to game
    @IBAction func pressedPlayWithoutSong(sender: AnyObject) {
        self.delegate?.userDidPressPlayWithoutSong()
    }
    

    // the button labeled "choose muse" - shold launch mediaPickerController
    @IBAction func pressedPickaSong(sender: AnyObject) {
        self.delegate?.userDidPressSelectSong()
    }
    
}
