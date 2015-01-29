//
//  MediaItemTableViewController.swift
//  DoctorWizard
//
//  Created by Brian Ledbetter on 1/27/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import UIKit
import MediaPlayer

protocol SongPickerDelegate {
    func userDidSelectSong(song : MPMediaItemCollection)
}

class MediaItemTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate {
    
    var mediaQuery : MPMediaQuery?
    var delegate : SongPickerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var navBar: UINavigationBar!
    @IBAction func cancelAction(sender: UIBarButtonItem) {
    
        println("cancel")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
//MARK: VIEW DID LOAD ============================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        // populate the tableview
        fetchItemsFromDeviceLibrary()
        
        navBar.delegate = self
    }

    
//MARK: TableViewDataSource functions ============================
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SONG_CELL", forIndexPath: indexPath) as MediaItemCell
        
        var mediaItem = mediaQuery?.items[indexPath.row] as MPMediaItem
        
        if let songName = mediaItem.title {
            cell.song.text = songName
        }
        
        if let artistName = mediaItem.artist {
            cell.artist.text = artistName
        } else {
            cell.artist.text = nil
        }
        
        if let songImage = mediaItem.artwork {
            cell.songImage.image = songImage.imageWithSize(CGSize(width: 50, height: 50))
        } else {
            cell.songImage.image = UIImage(named: "dude0.png")
            cell.songImage.contentMode = UIViewContentMode.ScaleAspectFit
        }
        
        if let songDuration = mediaItem.playbackDuration as NSTimeInterval? {
            
            var minutesFormatter = NSNumberFormatter()
            minutesFormatter.numberStyle = NSNumberFormatterStyle.NoStyle
            
            var minutes = minutesFormatter.stringFromNumber(floor(songDuration/60))!
            
            var secondsFormatter = NSNumberFormatter()
            secondsFormatter.numberStyle = NSNumberFormatterStyle.NoStyle
            secondsFormatter.roundingMode = NSNumberFormatterRoundingMode.RoundUp
            
            var seconds = songDuration - floor(songDuration/60)*60
            
            cell.songDuration.text = "\(minutes)m \(secondsFormatter.stringFromNumber(seconds)!)s"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaQuery!.items.count
    }
    
    
//MARK: TableViewDelegate ========================================
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let song = mediaQuery!.items[indexPath.row] as MPMediaItem
        let songCollection = MPMediaItemCollection(items: [song])
        println(self.delegate?)
        delegate?.userDidSelectSong(songCollection)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    
//MARK: METHODS ==================================================

    func fetchItemsFromDeviceLibrary(){
        self.mediaQuery = MPMediaQuery.songsQuery()
        mediaQuery?.items
    }
    


}
