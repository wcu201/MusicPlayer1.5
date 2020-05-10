//
//  ViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 9/3/17.
//  Copyright © 2017 William  Uchegbu. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import ID3TagEditor


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AVAudioPlayerDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var nowPlaying: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Console: UILabel!
    
    @IBOutlet weak var playPauseBTN: UIButton!
    @IBOutlet weak var backgroundArt: UIImageView!
    @IBOutlet weak var nowPlayingBar: UIView!
    @IBOutlet weak var artworkPlaying: UIImageView!
    @IBOutlet weak var titlePlaying: UILabel!
    @IBOutlet weak var artistPlaying: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var currentSong: URL?
    var isSearching: Bool = false
    var selectedSong: URL?
    var currentLibray = [URL]()
    
    override func viewWillAppear(_ animated: Bool) {
        //isSearching = false
        tableView.reloadData()
        
        guard appDelegate.musicPlaying else {
            return
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {isSearching = false}
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {isSearching = false}
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {isSearching = false}
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        userData.filteredMap.removeAll()
        userData.filteredLibrary.removeAll()
        userData.filteredPositions.removeAll()
        for (index, song) in (currentLibray.enumerated()){
            if (getTitle(songURL: song).lowercased()).range(of: searchText.lowercased()) != nil {
                userData.filteredMap[index] = song
                userData.filteredLibrary.append(song)
                userData.filteredPositions.append(index)
            }
        }
        
        if(userData.filteredMap.isEmpty) {isSearching = false}
        else {isSearching = true}
        
        if(userData.filteredLibrary.isEmpty) {isSearching = false}
        else {isSearching = true}
        self.tableView.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1:
                if isSearching{return userData.filteredLibrary.count}
                return appDelegate.selectedLibrary.count
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "shuffleCell") as? ShuffleTableViewCell
            cell?.shuffleBTN.addTarget(self, action: #selector(shufflePlay), for: .touchUpInside)
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? songTableViewCell
        
            if isSearching {
                // Ignore until I fix searching
                cell?.titleText.text = getTitle(songURL: (userData.filteredLibrary[indexPath.row]))
                cell?.artistText.text = getArtist(songURL: (userData.filteredLibrary[indexPath.row]))
                cell?.artwork.image = getImage(songURL: (userData.filteredLibrary[indexPath.row]))
                cell?.editBTN.setTitle(userData.filteredLibrary[indexPath.row].absoluteString, for: .normal)
                cell?.editBTN.addTarget(self, action: #selector(goToMetadataVC), for: .touchUpInside)
            }
            else {
                // This helps agains tableview scroll slowdown but makes a weird effect when scrolling fast. I consider this an improvment from the previous behavior but can definitely be improved upon
                cell?.artwork.image = #imageLiteral(resourceName: "album-cover-placeholder-light")
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let self = self else {
                      return
                    }
                    let url = self.appDelegate.selectedLibrary[indexPath.row]
                     
                    let image = getImage(songURL: url)
                    let title = getTitle(songURL: url)
                    let artist = getArtist(songURL: url)
                    DispatchQueue.main.async {
                        cell?.artwork.image = image
                        cell?.titleText.text = title
                        cell?.artistText.text = artist
                    }
                }
                
                cell?.editBTN.setTitle(appDelegate.selectedLibrary[indexPath.row].absoluteString, for: .normal)
                cell?.editBTN.addTarget(self, action: #selector(goToMetadataVC), for: .touchUpInside)
            }
        
            return cell!
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "")
            return cell!
        }
    }
    
    @objc func goToMetadataVC(sender: UIButton){
        let url = URL(string: sender.currentTitle!)
        selectedSong = url!
        print("URL: ", url!)
        self.performSegue(withIdentifier: "goToMetadata", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            appDelegate.currentPlaylist = NSMutableOrderedSet(array: appDelegate.selectedLibrary)
            currentSong = (appDelegate.currentPlaylist[indexPath.row] as! URL)
            //currentSong = appDelegate.selectedLibrary[indexPath.row]
            appDelegate.arrayPos = indexPath.row
        
            do {AppDelegate.sharedPlayer = try AVAudioPlayer(contentsOf:
                (appDelegate.currentPlaylist[indexPath.row] as! URL)
                //appDelegate.selectedLibrary[indexPath.row]
                )}
            catch{
                // TODO: Handle URL Error
            }
            
            AppDelegate.sharedPlayer.delegate = appDelegate
            AppDelegate.sharedPlayer.prepareToPlay()
            AppDelegate.sharedPlayer.play()
            appDelegate.musicPlaying = true
            appDelegate.songPlaying = currentSong
            
            musicVC.isShuffled = false
            

            if appDelegate.playerVC == nil {
                //No Music Player exists, so some setup needs to be done
                MusicController().attachToCommandCenter()
                let vc = MusicPlayerViewController(songURL: currentSong!)
                appDelegate.playerVC = vc
                vc.modalPresentationStyle = .popover
            }

            self.present(appDelegate.playerVC!, animated: true, completion: nil)
            

        /*
        if(isSearching){
            //MvC.url = (userData.filteredLibrary[indexPath.row])
            currentSong = (userData.filteredLibrary[indexPath.row])
            //musicVC.songVC = MvC
            musicVC.playerExists = true
            musicVC.arrayPos = userData.filteredPositions[indexPath.row]
            populateNowPlayBar(url: currentSong!)
            (musicVC.nav.viewControllers[0] as! LibraryViewController).populateNowPlyingBar(url: currentSong!)
            do {
                musicVC.player = try AVAudioPlayer(contentsOf: (userData.filteredLibrary[indexPath.row]))
            }
            catch{print("Song does not exist.")}
            isSearching = false
            searchBar.text = ""
            searchBar.endEditing(true)
            musicVC.player?.prepareToPlay()
            musicVC.player?.play()
        }
        
        else {
            //MvC.url = userData.songLibrary[indexPath.row]
            //MvC.url = userData.downloadLibrary[indexPath.row]
            
            //currentSong = userData.downloadLibrary[indexPath.row]
            currentSong = currentLibray[indexPath.row]
            
            //musicVC.songVC = MvC
            musicVC.playerExists = true
            musicVC.arrayPos = indexPath.row
            //populateNowPlayBar(url: MvC.url)
            
            //populates now playing bar for all songs view
            populateNowPlayBar(url: currentSong!)
            //populates now playing bar for library view
            (musicVC.nav.viewControllers.first as! LibraryViewController).populateNowPlyingBar(url: currentSong!)
            (musicVC.nav.viewControllers.first as! LibraryViewController).nowPlaying = currentSong!
        
        do { musicVC.player = try AVAudioPlayer(contentsOf: currentLibray[indexPath.row])
            //musicVC.player = try AVAudioPlayer(contentsOf: userData.downloadLibrary[indexPath.row])
        }
        catch{print("Song does not exist.")}
        
        musicVC.player?.prepareToPlay()
        musicVC.player?.play()
        }
    
        musicVC.isShuffled = false
        //self.navigationController?.pushViewController(MvC, animated: true)
        //self.present(MvC, animated: true, completion: nil)
        if musicVC.songVC.artwork != nil {
            musicVC.songVC.url = currentSong!
            musicVC.songVC.setup(theURL: currentSong!)
            show(musicVC.songVC, sender: self)
        }
        else {
            self.performSegue(withIdentifier: "showMusic", sender: self)
            }
 */
        }
 
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    
    @IBAction func nowPlaying(_ sender: Any) {
        show(appDelegate.playerVC!, sender: self)
        //performSegue(withIdentifier: "showMusic", sender: self)
        //self.present((self.navigationController?.viewControllers.last)!, animated: true, completion: nil)
        //self.show((self.navigationController?.viewControllers.last)!, sender: self)
    }

    
    func showNowPlaying(){
      nowPlaying.isHidden = false
      nowPlaying.isEnabled = true
    }

    func addContraintsToNowPlayingBar(){
        nowPlayingBar.translatesAutoresizingMaskIntoConstraints = true
        
        let widthConstraint = NSLayoutConstraint(item: nowPlayingBar, attribute: .width, relatedBy: .equal, toItem: self.tabBarController?.tabBar, attribute: .width, multiplier: 1.0, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: nowPlayingBar, attribute: .height, relatedBy: .equal, toItem: self.tabBarController?.tabBar, attribute: .height, multiplier: 1.0, constant: 0)
        let xConstraint = NSLayoutConstraint(item: nowPlayingBar, attribute: .leading, relatedBy: .equal, toItem: self.tabBarController?.tabBar, attribute: .leading, multiplier: 1.0, constant: 0)
        let yConstraint = NSLayoutConstraint(item: nowPlayingBar, attribute: .bottom, relatedBy: .equal, toItem: self.tabBarController?.tabBar, attribute: .top, multiplier: 1.0, constant: 0)
        
        self.view.addConstraints([widthConstraint, heightConstraint, xConstraint, yConstraint])
        
    }
    
    @objc func populateNowPlayBar(){
        let url = AppDelegate.sharedPlayer.url!
        nowPlayingBar.isHidden = false
        artworkPlaying.image = getImage(songURL: url)
        backgroundArt.image = getImage(songURL: url)
        titlePlaying.text = getTitle(songURL: url)
        artistPlaying.text = getArtist(songURL: url)
        if AppDelegate.sharedPlayer.isPlaying {playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_pause_circle_filled_black_48pt"), for: .normal)}
        else {playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_play_circle_filled_white_black_48pt"), for: .normal)}
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete", handler: {(action, other) in
            openBoolAlert(title: "Delete Song", message: "Are you sure you want to delete this song?", view: self, action: {() in
                print("Action Called: Delete", self.appDelegate.downloadLibrary[indexPath.row])
                self.appDelegate.deleteFromLibrary(url: self.appDelegate.selectedLibrary[indexPath.row])
                tableView.reloadData()
            })
        })
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: {(action, other) in
            self.selectedSong = self.appDelegate.selectedLibrary[indexPath.row]
            self.performSegue(withIdentifier: "goToMetadata", sender: self)
        })
        
        deleteAction.backgroundColor = UIColor.red
        editAction.backgroundColor = UIColor.blue
        
        return [deleteAction, editAction]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMetadata" {
            let vc = segue.destination as? MetadataViewController
            vc?.songURL = selectedSong
        }
        
    }

    @objc func shufflePlay() {
        if (!appDelegate.selectedLibrary.isEmpty){
//            appDelegate.shuffledLibrary = appDelegate.selectedLibrary
//            appDelegate.shuffledLibrary.shuffle()
//            appDelegate.isShuffled = true
//            appDelegate.musicPlaying = true
            
            AppDelegate.sharedPlayer.stop()
            appDelegate.currentUnshuffledPlaylist = NSMutableOrderedSet(array: appDelegate.selectedLibrary)
            var shuffledPlaylist = appDelegate.selectedLibrary
            shuffledPlaylist.shuffle()
            appDelegate.currentPlaylist = NSMutableOrderedSet(array: shuffledPlaylist)
            
//            currentSong = appDelegate.shuffledLibrary[0]
//            appDelegate.songPlaying = currentSong
//            appDelegate.arrayPos = 0
            
            currentSong = (appDelegate.currentPlaylist[0] as! URL)
            appDelegate.songPlaying = currentSong
            appDelegate.arrayPos = 0
            
            do {
                AppDelegate.sharedPlayer = try AVAudioPlayer(contentsOf: currentSong!)
            }
            catch {
                // TODO: Handle URL error
            }
            
            AppDelegate.sharedPlayer.delegate = appDelegate
            AppDelegate.sharedPlayer.prepareToPlay()
            AppDelegate.sharedPlayer.play()
            appDelegate.musicPlaying = true
            
            if appDelegate.playerVC == nil {
                //No Music Player exists, so some setup needs to be done
                MusicController().attachToCommandCenter()
                let vc = MusicPlayerViewController(songURL: currentSong!)
                appDelegate.playerVC = vc
                vc.modalPresentationStyle = .popover
            }

            self.present(appDelegate.playerVC!, animated: true, completion: nil)
            appDelegate.isShuffled = true
        }
        
    }
        
    
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
