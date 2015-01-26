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
    
    var song : MPMediaItem?
    
    var didPickMusic = false
    let menuAlertController = UIAlertController(title: NSLocalizedString("DoctorWizard", comment: "main menu title"), message: NSLocalizedString("GET READDDDDY", comment: "main menu message"), preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting the background color
//        if let popOverController = self.menuAlertController.popoverPresentationController{
//            
//            let fakeView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//            fakeView.center = CGPoint(x: self.view.center.x, y: self.view.center.y + (self.view.frame.height / 3))
//            self.view.addSubview(fakeView)
//            popOverController.sourceRect = fakeView.frame
//            popOverController.sourceView = fakeView
//        }
        self.view.backgroundColor = UIColor.purpleColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        // set up the main menu button
        if !didPickMusic {
            setUpMainButton()
        }
    }
    
    func setUpMainButton(){
        let playOption = UIAlertAction(title: NSLocalizedString("CHOOSE MUSE", comment: "the play button"), style: .Default) { (action) -> Void in
            // setting up the MediaPickerController as the MPMediaPlayerDelegate
            let musicPickerController = MPMediaPickerController()
            musicPickerController.allowsPickingMultipleItems = false
            musicPickerController.delegate = self
            self.presentViewController(musicPickerController, animated: true, completion: nil)
        }
        menuAlertController.addAction(playOption)
        
        self.presentViewController(menuAlertController, animated: true, completion: nil)
    }
    
    //MARK: MediaPickerController Options
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
        didPickMusic = !didPickMusic
        mediaPicker.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.presentViewController(GameViewController(), animated: true, completion: nil)
            
        })
        self.playMusic(mediaItemCollection)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//MARK: MPMusicPlayerController
    func playMusic(music: MPMediaItemCollection) -> () {
        let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
        musicPlayer.setQueueWithItemCollection(music)
        musicPlayer.play()
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
