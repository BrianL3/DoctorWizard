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
    func userDidCancel()
}

class MediaItemTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var mediaQuery : MPMediaQuery?
    var delegate : SongPickerDelegate?
    
    var filteredSongs : [MPMediaItem]?
    var unfilteredSongs : [MPMediaItem]?
    
    @IBOutlet weak var tableView: UITableView!

    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet var searchDisplay: UISearchDisplayController!
    
    
    @IBOutlet var navBar: UINavigationBar!
    @IBAction func cancelAction(sender: UIBarButtonItem) {
    
//        println("cancel")
        delegate?.userDidCancel()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
//MARK: VIEW DID LOAD ============================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // populate the tableview
        fetchItemsFromDeviceLibrary()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.searchBar.delegate = self
        self.searchDisplay.delegate = self
        
        let nib = UINib(nibName: "MediaItemCell", bundle: NSBundle.mainBundle())

        
        self.tableView.registerNib(nib, forCellReuseIdentifier: "SONG_CELL")
        searchDisplay.searchResultsTableView.registerNib(nib, forCellReuseIdentifier: "SONG_CELL")
        searchDisplay.searchResultsTableView.rowHeight = 78.0
//        self.tableView.registerClass(MediaItemCell.self, forCellReuseIdentifier: "SONG_CELL")
//        self.searchDisplay.searchResultsTableView.registerClass(MediaItemCell.self, forCellReuseIdentifier: "SONG_CELL")
        
        navBar.delegate = self
    }

    
//MARK: TableViewDataSource functions ============================
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var mediaItem = MPMediaItem();
        if tableView == self.searchDisplay!.searchResultsTableView{
            mediaItem = filteredSongs![indexPath.row] as MPMediaItem
        }else{
            mediaItem = unfilteredSongs![indexPath.row] as MPMediaItem
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("SONG_CELL", forIndexPath: indexPath) as MediaItemCell

        if let songName = mediaItem.title {
            cell.song.text = songName
        }
        
        if let artistName = mediaItem.artist {
            cell.artist.text = artistName
        }
        
        if let songImage = mediaItem.artwork {
            cell.songImage.image = songImage.imageWithSize(CGSize(width: 50, height: 50))
        } else {
            cell.songImage.image = UIImage(named: "dude.png")
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
        if tableView == self.searchDisplay!.searchResultsTableView{
            return filteredSongs!.count
        }
        return mediaQuery!.items.count
    }
    
    
//MARK: TableViewDelegate ========================================
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let song = mediaQuery!.items[indexPath.row] as MPMediaItem
        let songCollection = MPMediaItemCollection(items: [song])
        delegate?.userDidSelectSong(songCollection)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    
//MARK: METHODS ==================================================

    //fills tableview with mediaitems from device library
    func fetchItemsFromDeviceLibrary(){
        self.mediaQuery = MPMediaQuery.songsQuery()
        
    self.unfilteredSongs = mediaQuery?.items as? [MPMediaItem]
        self.filteredSongs = self.unfilteredSongs
    }
    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        self.filteredSongs = self.unfilteredSongs!.filter({(song: MPMediaItem) -> Bool in
            let stringMatch = song.title.rangeOfString(searchText)
            return (stringMatch != nil)
        })
    }
//MARK: SearchController Protocol methods
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text)
        return true
    }


}
