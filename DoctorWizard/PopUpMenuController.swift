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
}
    

class PopUpMenuController: UIViewController {

    @IBOutlet weak var songNameLabel: UILabel!
    
    var delegate: popUpMenuDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    @IBAction func userDidPlaySong(sender: AnyObject) {
        
        //self.delegate?.userDidPlaySong()
        
        
    }
    
    
    
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
