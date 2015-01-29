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
    var songGenre : String = "DefaultDuncanSong"
    var scene : GameScene?
    var popUpVC = PopUpMenuController()
    let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
    var currentSong : MPMediaItemCollection?
    
    var didPickMusic = false

    
    //MARK: VIEW DID LOAD & APPEAR =============================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.launchGame()
        self.pauseGame()
        //create pop up controller
        popUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("PopUpVC") as PopUpMenuController
        popUpVC.delegate = self
        
        // frame  is 40% of screen
        let width           = self.view.frame.width * 0.85
        let height          = self.view.frame.height * 0.85
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
    
    //MARK: MUSIC PLAYER CONTROLLER ========================================================
    
    // the music will play
    func playMPMusic(music: MPMediaItemCollection, completionHandler : (genre: String?, duration: NSTimeInterval?) -> () ) {
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
       //popUpVC.view.removeFromSuperview()
        AnimationController.singleton.slideOffViewController(popUpVC)
        
    }
    
    
    
    //MARK: SongPickerDelegate
    func userDidSelectSong(song : MPMediaItemCollection){
        self.currentSong = song
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
        self.pauseGame()
        //create pop up controller
        popUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("PopUpVC") as PopUpMenuController
        popUpVC.delegate = self
        
        // frame  is 40% of screen
        let width           = self.view.frame.width * 0.85
        let height          = self.view.frame.height * 0.85
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
    
    func restartWithSameSong(usingDefaultSong : Bool){
        if usingDefaultSong{
            self.launchGame()
            pauseGame()
            userDidPressPlayWithoutSong()
        }else{
            self.launchGame()
            pauseGame()
            if musicPlayer.playbackState == .Playing {
                self.musicPlayer.skipToBeginning()
            }else{
                userDidSelectSong(currentSong!)
            }
            unpauseGame()
        }
    }
    
    func restartWithDifferentSong(){
        self.launchGame()
        pauseGame()
        userDidPressSelectSong()
    }
}
