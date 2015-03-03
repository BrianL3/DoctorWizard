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
    
    var songDuration : NSTimeInterval = 5.0
    var songGenre : String = "DefaultDuncanSong"
    var scene : SpaceScene?
    var popUpVC = PopUpMenuController()
    let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
    var currentSong : MPMediaItemCollection?
    
    var didPickMusic = false

    
    //MARK: VIEW DID LOAD & APPEAR =============================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //authenticate the local user
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showAuthenticationViewController"), name: "PresentAuthenticationViewController", object: nil)
        GameCenterKit.sharedGameCenter.authenticateLocalPlayer()
        
        
        self.launchGame()
        self.pauseGame()
        //create pop up controller
        popUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("PopUpVC") as PopUpMenuController
        popUpVC.delegate = self
        
        //MARK: Main Menu Frame
        let width           = self.view.frame.width * 1.0
        let height          = self.view.frame.height * 1.0
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
    //MARK: AUTHENTICATION
    
    func showAuthenticationViewController(){
        if let authenticationViewController = GameCenterKit.sharedGameCenter.authenticationViewController {
            self.presentViewController(authenticationViewController, animated: true, completion: nil)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
// MARK: Game Funcs
    func launchGame(){
        self.scene = nil
        self.scene = SpaceScene(size:CGSize(width: 2048, height: 1536))
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
        
        let song = musicPlayer.nowPlayingItem
        
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
        popUpVC.view.removeFromSuperview()

    }
    
    func userDidPressPlayWithoutSong(){
        SKTAudio.sharedInstance().playSoundEffect("tick_two.wav")
        self.playSKMusic()
        self.scene?.paused = false
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
    }
    
    func userDidCancel(){
        //create pop up controller
        popUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("PopUpVC") as PopUpMenuController
        popUpVC.delegate = self
        
        //MARK: Main Menu Frame
        let width           = self.view.frame.width * 1.0
        let height          = self.view.frame.height * 1.0
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
    
    //MARK: MAIN MENU DELEGATE
    func playerDidLose(){
        self.pauseGame()
        //create pop up controller
        popUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("PopUpVC") as PopUpMenuController
        popUpVC.delegate = self
        
        let width           = self.view.frame.width * 1.0
        let height          = self.view.frame.height * 1.0
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
            self.songDuration = 100.0
            self.songGenre = "DefaultDuncanSong"

            self.launchGame()
            pauseGame()
            SKTAudio.sharedInstance().playSoundEffect("tick_two.wav")
            self.playSKMusic()

            unpauseGame()

        }else{
            if musicPlayer.playbackState == .Playing {
                self.musicPlayer.skipToBeginning()
            }else{
                userDidSelectSong(currentSong!)
            }
            self.launchGame()
            unpauseGame()
        }
    }
    
    func restartWithDifferentSong(){
        self.launchGame()
        pauseGame()
        userDidPressSelectSong()
    }
}
