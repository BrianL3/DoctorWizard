//
//  MainMenuViewController.swift
//  DoctorWizard
//
//  Created by Brian Ledbetter on 1/26/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import UIKit
import MediaPlayer

class MainMenuViewController: UIViewController, MPMediaPickerControllerDelegate, popUpMenuDelegate {
    
    var song : MPMediaItem?
    
    var didPickMusic = false
    
    let menuAlertController = UIAlertController(title: NSLocalizedString("DoctorWizard", comment: "main menu title"), message: NSLocalizedString("GET READDDDDY", comment: "main menu message"), preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        //create pop up controller
        let popUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("PopUpVC") as PopUpMenuController
        
        popUpVC.delegate = self
        
        
        
        // frame  is 40% of screen
        let width = self.view.frame.width * 0.4
        let height = self.view.frame.height * 0.4
        
        popUpVC.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        popUpVC.view.center = self.view.center
        
        
        self.view.addSubview(popUpVC.view)
    
        //tell child and parent vcs that the child is being added to the parent
        
        //told parent vc that child vc was added
        self.addChildViewController(popUpVC)
        
        //told child it has a parent
        popUpVC.didMoveToParentViewController(self)
        
        
        //do animation
        
        popUpVC.view.alpha = 0
        
        //do trasform
        popUpVC.view.transform = CGAffineTransformMakeScale(1.2, 1.2)
        
        //do animation
        UIView.animateWithDuration(0.2, delay: 0.5, options: nil, animations: { () -> Void in
            
            popUpVC.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            popUpVC.view.alpha = 1

            
            
        }) { (finished) -> Void in
            
        }
        
    }
    
    //MARK: MediaPickerController Options
    
    // if the user cancels out of choosing a song - dismisses the modal
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    // if the user picks a song it (1) fires PlayMusic and (2) dismisses the MediaPicker and then (3) summons GameViewController
    func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
        didPickMusic = !didPickMusic
        // (1) firing playMusic
        self.playMusic(mediaItemCollection, completionHandler: { (genre, duration) -> () in
            //println("found songToPlay, duration of \(duration) and genre \(genre)")
            // (2) dismissing the MediaPicker
            mediaPicker.dismissViewControllerAnimated(true, completion: { () -> Void in
                // create the GameViewController
                let mainGameScene = GameViewController()
                mainGameScene.songDuration = duration
                mainGameScene.songGenre = genre
                let songToPlay = mediaItemCollection[0] as? MPMediaItem
                // (3) presenting the GameViewController
                self.presentViewController(mainGameScene, animated: true, completion: nil)
                
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK: MPMusicPlayerController
    // the music will play
    func playMusic(music: MPMediaItemCollection, completionHandler : (genre: String?, duration: NSTimeInterval?) -> () ) {
        let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
        musicPlayer.setQueueWithItemCollection(music)
        musicPlayer.play()
        
        self.song = musicPlayer.nowPlayingItem
        
        completionHandler(genre: song?.genre, duration: song?.playbackDuration)
    }
    
//MARK: PopUpMenuDelegateFunction
    // what happens when the user selects the pick a song button
    func userDidPressSelectSong(){
        
        // setting up the MediaPickerController as the MPMediaPlayerDelegate
        let musicPickerController = MPMediaPickerController()
        musicPickerController.allowsPickingMultipleItems = false
        musicPickerController.delegate = self
        self.presentViewController(musicPickerController, animated: true, completion: nil)
    }
    
    func userDidPressPlayWithoutSong(){
        let mainGameScene = GameViewController()
        mainGameScene.songDuration = NSTimeInterval(100.00)
        mainGameScene.songGenre = "Alternative"
        self.presentViewController(mainGameScene, animated: true, completion: nil)
        
    }
    
    
    
    
}
