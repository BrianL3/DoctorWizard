//
//  MainMenuViewController.swift
//  DoctorWizard
//
//  Created by Brian Ledbetter on 1/26/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import UIKit
import MediaPlayer
import SpriteKit


class MainMenuViewController: UIViewController, MPMediaPickerControllerDelegate, popUpMenuDelegate {
    
    var song : MPMediaItem?
    var songDuration : NSTimeInterval?
    var songGenre : String?
    var scene : GameScene?
    
    var didPickMusic = false

    
    //MARK: VIEW DID LOAD & APPEAR =============================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        //create pop up controller
        let popUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("PopUpVC") as PopUpMenuController
        popUpVC.delegate = self
        
        // frame  is 40% of screen
        let width           = self.view.frame.width * 0.4
        let height          = self.view.frame.height * 0.4
        popUpVC.view.frame  = CGRect(x: 0, y: 0, width: width, height: height)
        popUpVC.view.center = self.view.center
        
        self.view.addSubview(popUpVC.view)
    
        //told parent vc that child vc was added
        self.addChildViewController(popUpVC)
        
        //told child it has a parent
        popUpVC.didMoveToParentViewController(self)
        
        //do animation
        AnimationController.singleton.simpleFadeInScale(popUpVC)
    }
// MARK: Game Funcs
    func launchGame(){
        self.scene = GameScene(size:CGSize(width: 2048, height: 1536))
        let skView = SKView(frame: self.view.frame)
        self.view.addSubview(skView)
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        self.scene!.scaleMode = .AspectFill
        skView.presentScene(scene)

    }
    // hides the status bar
    override func prefersStatusBarHidden() -> Bool  {
        return true
    }
    
    func pauseGame(){
        self.scene?.paused = true
    }
    
    //MARK: MediaPickerController Options
    
    //MARK: MEDIA PICKER CONTROLLER OPTIONS ================================================
    
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
                self.songDuration = duration
                self.songGenre = genre
                let songToPlay = mediaItemCollection[0] as? MPMediaItem
                // (3) presenting the GameViewController
                self.launchGame()

            })
        })
    }

    
    //MARK: MP MUSIC PLAYER CONTROLLER ========================================================
    
    // the music will play
    func playMusic(music: MPMediaItemCollection, completionHandler : (genre: String?, duration: NSTimeInterval?) -> () ) {
        let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
        musicPlayer.setQueueWithItemCollection(music)
        musicPlayer.play()
        
        self.song = musicPlayer.nowPlayingItem
        
        completionHandler(genre: song?.genre, duration: song?.playbackDuration)
    }
    

    //MARK: POP UP MENU DELEGATE FUNCTIONS ===================================================
    
    // what happens when the user selects the pick a song button
    func userDidPressSelectSong(){
        
        // setting up the MediaPickerController as the MPMediaPlayerDelegate
        let musicPickerController = MPMediaPickerController()
        musicPickerController.allowsPickingMultipleItems = false
        musicPickerController.delegate = self
        self.launchGame()
    }
    
    func userDidPressPlayWithoutSong(){
        let mainGameScene = GameViewController()
        mainGameScene.songDuration = NSTimeInterval(100.00)
        mainGameScene.songGenre = "Alternative"
        self.presentViewController(mainGameScene, animated: true, completion: nil)
        
    }
    
    
    
    
}
