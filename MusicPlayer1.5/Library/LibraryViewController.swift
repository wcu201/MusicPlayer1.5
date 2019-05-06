//
//  LibraryViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/20/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit
import ID3TagEditor

class LibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var playPauseBTN: UIButton!
    @IBOutlet weak var nowPlayingBTN: UIButton!
    @IBOutlet weak var nowPlayingBar: UIView!
    @IBOutlet weak var artworkPlaying: UIImageView!
    @IBOutlet weak var backgroundArt: UIImageView!
    @IBOutlet weak var titlePlaying: UILabel!
    @IBOutlet weak var artistPlaying: UILabel!
    @IBOutlet weak var menu: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var nowPlaying: URL?
    let categories = ["All Songs", "Albums", "Artists", "Recently Added"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "category")
        cell?.textLabel?.text = categories[indexPath.row]
        cell?.textLabel?.font = UIFont(name: "Avenir Book", size: 17.0)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            if nowPlaying != nil {
                print("A song is playing")
            }
            else {
                print("No song playing")
            }
            
            if musicVC.nav.viewControllers.count > 1 {
                (musicVC.nav.viewControllers[1] as? ViewController)?.currentLibray = userData.downloadLibrary
                self.show(musicVC.nav.viewControllers[1], sender: self)
                //Every time I press back from all songs it deinits that view and thus when I press all songs again a new veiw is initialized without the now playing bar if a song was playing
                //A good solution would be just keeping track of if a song is playing and then populating the now playing bar if it is
            }
            else {
                performSegue(withIdentifier: "showAllSongs", sender: self)
                //musicVC.allSongsVC
            }
        }
        if indexPath.row == 1 {
            performSegue(withIdentifier: "showAlbums", sender: self)
        }
        if indexPath.row == 2 {
            performSegue(withIdentifier: "showArtists", sender: self)
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        musicVC.nav = self.navigationController!
        self.navigationController?.tabBarController?.viewControllers?.forEach{let _=$0.view}
        
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showNowPlaying(_ sender: Any) {
        //self.show(musicVC.songVC, sender: self)
        self.show(appDelegate.playerVC!, sender: self)
    }
    
    @IBAction func playPause(_ sender: Any) {
        if !(appDelegate.player.isPlaying/*musicVC.player?.isPlaying*/) {
            //musicVC.player?.play()
            appDelegate.player.play()
            playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_pause_circle_filled_black_48pt"), for: .normal)
            //musicVC.songVC.playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
            appDelegate.playerVC?.playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
        }
            
        else {
            //musicVC.player?.pause()
            appDelegate.player.pause()
            playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_play_circle_filled_white_black_48pt"), for: .normal)
            //musicVC.songVC.playPauseButton.setImage(#imageLiteral(resourceName: "play_arrow_white_54x54"), for: .normal)
            appDelegate.playerVC?.playPauseButton.setImage(#imageLiteral(resourceName: "play_arrow_white_54x54"), for: .normal)
        }
        
        
    }
    
    
    func populateNowPlyingBar(url: URL){
        nowPlayingBar.isHidden = false
        artistPlaying.text = getArtist(songURL: url)
        titlePlaying.text = getTitle(songURL: url)
        artworkPlaying.image = getImage(songURL: url)
        backgroundArt.image = getImage(songURL: url)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.restorationIdentifier == "songs"{
            let vc = segue.destination as? ViewController
            vc?.currentLibray = userData.downloadLibrary
            if nowPlaying != nil {
                vc?.currentSong = nowPlaying
            }
        }
    }
    

}
