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



class MainMenuViewController: UIViewController, MPMediaPickerControllerDelegate, popUpMenuDelegate, SongPickerDelegate, MainMenuDelegate {
    
    var song : MPMediaItem?
    var songDuration : NSTimeInterval = 100.0
    var songGenre : String = "Alternative"
    var scene : GameScene?
    var popUpVC = PopUpMenuController()
    
    var didPickMusic = false

    
    //MARK: VIEW DID LOAD & APPEAR =============================================================
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.launchGame()
        self.pauseGame()
        
        //create pop up controller
        popUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("PopUpVC") as PopUpMenuController
        popUpVC.delegate = self
        
        // create frame
        let width           = self.view.frame.width * 0.95
        let height          = self.view.frame.height * 0.95
        popUpVC.view.frame  = CGRect(x: 0, y: 0, width: width, height: height)
        popUpVC.view.center = self.view.center
        
        self.view.addSubview(popUpVC.view)
        
        //told parent vc that child vc was added
        self.addChildViewController(popUpVC)
        
        //told child it has a parent
        popUpVC.didMoveToParentViewController(self)
        
        //AnimationController.singleton.slideOnViewController(popUpVC)
        AnimationController.singleton.bounceInViewController(popUpVC)

    }

    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
    }
    
    
// MARK: Game Funcs
    func launchGame(){
        self.scene = nil
        self.scene = GameScene(size:CGSize(width: 2048, height: 1536))
        println(self.songGenre)
        scene?.songGenre = self.songGenre
        println(self.songDuration)
        scene?.songDuration = self.songDuration
        scene?.menuDelegate = self
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
    func unpauseGame(){
        self.scene?.paused = false
    }
    
    //MARK: MEDIA PICKER CONTROLLER OPTIONS ================================================
    
    // if the user cancels out of choosing a song - dismisses the modal
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    // if the user picks a song it (1) fires PlayMusic and (2) dismisses the MediaPicker and then (3) summons GameViewController
    func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
        didPickMusic = !didPickMusic
        // (1) firing playMusic
        self.playMPMusic(mediaItemCollection, completionHandler: { (genre, duration) -> () in
            //println("found songToPlay, duration of \(duration) and genre \(genre)")
            // (2) dismissing the MediaPicker
            mediaPicker.dismissViewControllerAnimated(true, completion: { () -> Void in
                // create the GameViewController
                let songToPlay = mediaItemCollection[0] as? MPMediaItem
                // (3) presenting the GameViewController
                if duration != nil{
                    self.songDuration = duration!
                }
                if genre != nil{
                    self.songGenre = genre!
                }
                self.unpauseGame()

            })
        })
    }

    
    //MARK: MUSIC PLAYER CONTROLLER ========================================================
    
    // the music will play
    func playMPMusic(music: MPMediaItemCollection, completionHandler : (genre: String?, duration: NSTimeInterval?) -> () ) {
        let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
        musicPlayer.setQueueWithItemCollection(music)
        musicPlayer.play()
        
        self.song = musicPlayer.nowPlayingItem
        
        completionHandler(genre: song?.genre, duration: song?.playbackDuration)
    }

    // play music with SKAudio
    func playSKMusic(){
        SKTAudio.sharedInstance().playBackgroundMusic("lux.wav")
    }
    

    //MARK: POP UP MENU DELEGATE FUNCTIONS ===================================================
    
    // what happens when the user selects the pick a song button
    func userDidPressSelectSong(){
        SKTAudio.sharedInstance().playSoundEffect("tick_one.wav")
        let destinationVC = self.storyboard?.instantiateViewControllerWithIdentifier("MEDIA_VC") as MediaItemTableViewController    
        destinationVC.delegate = self
        self.presentViewController(destinationVC, animated: true, completion: nil)
    }
    
    func userDidPressPlayWithoutSong(){
        SKTAudio.sharedInstance().playSoundEffect("tick_two.wav")
        self.playSKMusic()
        self.scene?.paused = false
        AnimationController.singleton.slideOffViewController(popUpVC)
        //popUpVC.view.removeFromSuperview()
    }
    
    
    
    //MARK: SongPickerDelegate
    func userDidSelectSong(song : MPMediaItemCollection){
        playMPMusic(song, completionHandler: { (genre, duration) -> () in
            self.unpauseGame()
            if duration != nil{
                self.scene!.songDuration = duration!
            }
            if genre != nil{
                self.scene!.songGenre = genre!
            }
        })
        popUpVC.view.removeFromSuperview()
    }
    
    //MARK: MAIN MENU DELEGATE
    func playerDidLose(){
        self.launchGame()
        self.pauseGame()
        //create pop up controller
        popUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("PopUpVC") as PopUpMenuController
        popUpVC.delegate = self
        
    //MARK: MAIN MENU
        let width           = self.view.frame.width * 0.95
        let height          = self.view.frame.height * 0.95
        popUpVC.view.frame  = CGRect(x: 0, y: 0, width: width, height: height)
        popUpVC.view.center = self.view.center
        
        self.view.addSubview(popUpVC.view)
        
        //told parent vc that child vc was added
        self.addChildViewController(popUpVC)
        
        //told child it has a parent
        popUpVC.didMoveToParentViewController(self)
        
        //do animation
        AnimationController.singleton.bounceInViewController(popUpVC)

    }
    
    func relaunchGameWithSameSong() {
        // something
        println("going to relaunch with same song")
    }
    
    func chooseNewSong() {
        // something
        println("going to choose new song")

    }
}
