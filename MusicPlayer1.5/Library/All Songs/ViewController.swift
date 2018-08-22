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



struct tableVC {
    //static var library = ViewController()
}

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
    
    var currentSong: URL?
    var isSearching: Bool = false
    var selectedSong: URL?
    var currentLibray = [URL]()
    //var songLibrary: [URL] = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: "Music Library")!
    
    override func viewWillAppear(_ animated: Bool) {
        //isSearching = false
        tableView.reloadData()
        /*do {
            let id3TagEditor = ID3TagEditor()
            let tag = ID3Tag(version: .version3,
                             artist: "Usher",
                             albumArtist: "Usher",
                             album: "Confessions",
                             title: "Burn",
                             year: "2004",
                             genre: Genre(genre: ID3Genre.RAndB, description: "Rhythm & Blues"),
                             attachedPictures: [],
                             trackPosition: TrackPositionInSet(position: 6, totalTracks: 17))
            //ID3TagEditor.read(<#T##ID3TagEditor#>)
            //try ID3TagEditor.write(ID3TagEditor())
            print("Path: ", userData.downloadLibrary[4].path)
            try id3TagEditor.write(tag: tag, to: userData.downloadLibrary[4].path)
        } catch {
            print("Error editing tag: ", error)
        }
        */
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        //tableVC.library = self
        
        musicVC.player?.delegate = self

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
        //for (index, song) in userData.downloadLibrary.enumerated(){
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
            //return userData.songLibrary.count
            //return userData.downloadLibrary.count
            return currentLibray.count
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
                /*
                 cell.textLabel?.text = getTitle(songURL: (userData.filteredLibrary[indexPath.row]))
                cell.detailTextLabel?.text = getArtist(songURL: (userData.filteredLibrary[indexPath.row]))
                cell.imageView?.image = getImage(songURL: (userData.filteredLibrary[indexPath.row]))*/
                cell?.titleText.text = getTitle(songURL: (userData.filteredLibrary[indexPath.row]))
                cell?.artistText.text = getArtist(songURL: (userData.filteredLibrary[indexPath.row]))
                cell?.artwork.image = getImage(songURL: (userData.filteredLibrary[indexPath.row]))
                cell?.editBTN.setTitle(userData.filteredLibrary[indexPath.row].absoluteString, for: .normal)
                cell?.editBTN.addTarget(self, action: #selector(goToMetadataVC), for: .touchUpInside)
            }
            else {
                /*
                cell?.titleText.text = getTitle(songURL: userData.downloadLibrary[indexPath.row])
                cell?.artistText.text = getArtist(songURL: userData.downloadLibrary[indexPath.row])
                cell?.artwork.image = getImage(songURL: userData.downloadLibrary[indexPath.row])
                
                cell?.editBTN.setTitle(userData.downloadLibrary[indexPath.row].absoluteString, for: .normal)*/
                
                cell?.titleText.text = getTitle(songURL: currentLibray[indexPath.row])
                cell?.artistText.text = getArtist(songURL: currentLibray[indexPath.row])
                cell?.artwork.image = getImage(songURL: currentLibray[indexPath.row])
                
                cell?.editBTN.setTitle(currentLibray[indexPath.row].absoluteString, for: .normal)
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
        //let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let MvC = Storyboard.instantiateViewController(withIdentifier: "MusicViewController") as! MusicViewController
        
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
            populateNowPlayBar(url: currentSong!)
            (musicVC.nav.viewControllers.first as! LibraryViewController).populateNowPlyingBar(url: currentSong!)
        
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
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    
    @IBAction func nowPlaying(_ sender: Any) {
         show(musicVC.songVC, sender: self)
        //performSegue(withIdentifier: "showMusic", sender: self)
        //self.present((self.navigationController?.viewControllers.last)!, animated: true, completion: nil)
        //self.show((self.navigationController?.viewControllers.last)!, sender: self)
    }
    
    func getArtist(songURL: URL) -> String {
        var theArtist: String = "Unknow Artist"
        
        let item = AVPlayerItem(url: songURL)
        let metadata = item.asset.metadata
        
        for theItem in metadata {
            if theItem.commonKey == nil { continue }
            if let key = theItem.commonKey, let value = theItem.value {
                if key == "artist"
                {theArtist = value as! String}
            }
        }
        return theArtist
    }
    
    func getTitle(songURL: URL) -> String {
        var theTitle: String = "No Title"
        
        let item = AVPlayerItem(url: songURL)
        let metadata = item.asset.metadata
        
        for theItem in metadata {
            if theItem.commonKey == nil { continue }
            if let key = theItem.commonKey, let value = theItem.value {
                if key == "title"
                {theTitle = value as! String}
            }
        }
        return theTitle
    }
    
    func getImage(songURL: URL) -> UIImage {
        var theImage: UIImage = #imageLiteral(resourceName: "album-cover-placeholder-light")
        
        let item = AVPlayerItem(url: songURL)
        let metadata = item.asset.metadata
    
        for theItem in metadata {
            if theItem.commonKey == nil {continue}
            if let key = theItem.commonKey, let value = theItem.value{
                if key == "artwork"{
                    theImage = UIImage(data: value as! Data)!
                }
            }
        }
        return theImage
    }
    
    func showNowPlaying(){
      nowPlaying.isHidden = false
      nowPlaying.isEnabled = true
    }

    
    func populateNowPlayBar(url: URL){
        nowPlayingBar.isHidden = false
        artworkPlaying.image = getImage(songURL: url)
        backgroundArt.image = getImage(songURL: url)
        titlePlaying.text = getTitle(songURL: url)
        artistPlaying.text = getArtist(songURL: url)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMetadata" {
            let vc = segue.destination as? MetadataViewController
            vc?.songURL = selectedSong
        }
        
        if segue.identifier == "showMusic" {
            let vc = segue.destination as? MusicViewController
            vc?.url  = currentSong!
            musicVC.songVC = vc!
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        (self.navigationController?.viewControllers.first as? LibraryViewController)?.nowPlaying = currentSong
    }
    
    @objc func shufflePlay() {
        //userData.shuffledLibrary = userData.downloadLibrary
        userData.shuffledLibrary = currentLibray
        userData.shuffledLibrary.shuffle()
        musicVC.isShuffled = true
        
        currentSong = userData.shuffledLibrary[0]
        musicVC.playerExists = true
        musicVC.arrayPos = 0
        populateNowPlayBar(url: currentSong!)
        (musicVC.nav.viewControllers.first as? LibraryViewController)?.populateNowPlyingBar(url: currentSong!)
        
        do {musicVC.player = try AVAudioPlayer(contentsOf: currentSong!)}
        catch{print("Song does not exist.")}
        
        musicVC.player?.prepareToPlay()
        musicVC.player?.play()
        
        if musicVC.songVC.artwork != nil {
            musicVC.songVC.url = currentSong!
            musicVC.songVC.setup(theURL: currentSong!)
            show(musicVC.songVC, sender: self)
        }
        else {
            self.performSegue(withIdentifier: "showMusic", sender: self)
        }
    }

    
    @IBAction func playPause(_ sender: Any) {
        if !(musicVC.player?.isPlaying)! {
            musicVC.player?.play()
            playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_pause_circle_filled_black_48pt"), for: .normal)
            musicVC.songVC.playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
        }
            
        else {
            musicVC.player?.pause()
            playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_play_circle_filled_white_black_48pt"), for: .normal)
            musicVC.songVC.playPauseButton.setImage(#imageLiteral(resourceName: "play_arrow_white_54x54"), for: .normal)
        }
    }
    
    deinit {
        print ("VC deinits")
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
