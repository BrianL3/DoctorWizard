//
//  MainMenuViewController.swift
//  DoctorWizard
//
//  Created by Brian Ledbetter on 1/26/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import UIKit
import MediaPlayer

class MainMenuViewController: UIViewController, MPMediaPickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // creating the main menu alert controller
        let menuAlertController = UIAlertController(title: NSLocalizedString("DoctorWizard", comment: "main menu title"), message: NSLocalizedString("GET READDDDDY", comment: "main menu message"), preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // creating the select music button
        let musicSelectButton = UIButton()
        
        // setting up the MediaPickerController as the MPMediaPlayerDelegate
        let musicPickerController = MPMediaPickerController()
        musicPickerController.allowsPickingMultipleItems = false
        musicPickerController.delegate = self
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
