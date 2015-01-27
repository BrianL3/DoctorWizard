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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }
// the button labeled "Just go already" - should skip MediaPickerController and go direct to game
    @IBAction func pressedPlayWithoutSong(sender: AnyObject) {
        self.delegate?.userDidPressPlayWithoutSong()
    }
    
// the button labeled "choose muse" - shold launch mediaPickerController
    @IBAction func pressedPickaSong(sender: AnyObject) {
        self.delegate?.userDidPressSelectSong()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
