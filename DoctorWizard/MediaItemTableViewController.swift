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

class MediaItemTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var mediaQuery : MPMediaQuery?
    var delegate : SongPickerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        fetchItemsFromDeviceLibrary()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchItemsFromDeviceLibrary(){
        self.mediaQuery = MPMediaQuery.songsQuery()
        mediaQuery?.items
    }
//MARK: TableViewDataSource functions
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SONG_CELL", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = self.mediaQuery?.items[indexPath.row].title
        cell.detailTextLabel?.text = self.mediaQuery?.items[indexPath.row].artist
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaQuery!.items.count
    }
//MARK: TableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let song = mediaQuery!.items[indexPath.row] as MPMediaItem
        let songCollection = MPMediaItemCollection(items: [song])
        println(self.delegate)
        delegate?.userDidSelectSong(songCollection)
        self.dismissViewControllerAnimated(true, completion: nil)
        
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
