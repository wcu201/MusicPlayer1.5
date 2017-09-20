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

struct musicVC{
    static var player: AVAudioPlayer?
    static var sonPlaying: URL?
    static var songVC = MusicViewController()
    static var arrayPos = Int()
    static var playerExists: Bool = false
    static var nowPlayHidden: Bool = true
}

struct userData{
    static var songLibrary: [URL] = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: "Music Library")!
    static var filteredLibrary: [URL]?
    static var filteredMap = [Int: URL]()
}

struct tableVC {
    static var library = ViewController()
}



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AVAudioPlayerDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var nowPlaying: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Console: UILabel!
    
    
    @IBOutlet weak var nowPlayingBar: UIView!
    @IBOutlet weak var artworkPlaying: UIImageView!
    @IBOutlet weak var titlePlaying: UILabel!
    @IBOutlet weak var artistPlaying: UILabel!
    
    
    var isSearching: Bool = false

    //var songLibrary: [URL] = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: "Music Library")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableVC.library = self
        
        musicVC.player?.delegate = self
        
        //tableVC.library.testConsole()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        isSearching = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        isSearching = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        isSearching = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        isSearching = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        userData.filteredMap.removeAll()
        for (index, songs) in userData.songLibrary.enumerated()
        {if (getTitle(songURL: songs).lowercased()).range(of: searchText.lowercased()) != nil
        {
            userData.filteredMap[index] = songs}
        }
        
        
        
        if(userData.filteredMap.isEmpty)
        {isSearching = false}
        else
        {isSearching = true}
        
        self.tableView.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching
        {return userData.filteredMap.count}
        return userData.songLibrary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if isSearching
        {
        cell.textLabel?.text = getTitle(songURL: (userData.filteredMap[indexPath.row])!)
            
        cell.detailTextLabel?.text = getArtist(songURL: (userData.filteredMap[indexPath.row])!)
            
        cell.imageView?.image = getImage(songURL: (userData.filteredMap[indexPath.row])!)
        }
        else
        {
        cell.textLabel?.text = getTitle(songURL: userData.songLibrary[indexPath.row])
        
        cell.detailTextLabel?.text = getArtist(songURL: userData.songLibrary[indexPath.row])
        
        cell.imageView?.image = getImage(songURL: userData.songLibrary[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let MvC = Storyboard.instantiateViewController(withIdentifier: "MusicViewController") as! MusicViewController
        
        if(isSearching)
        {
            MvC.url = (userData.filteredLibrary?[indexPath.row])!
            musicVC.songVC = MvC
            musicVC.playerExists = true
            musicVC.arrayPos = indexPath.row
            
            do{
                musicVC.player = try AVAudioPlayer(contentsOf: (userData.filteredLibrary?[indexPath.row])!)}
            catch{print("Song does not exist.")}
            
            musicVC.player?.prepareToPlay()
            
            musicVC.player?.play()
            
        }
        
        else{
            MvC.url = userData.songLibrary[indexPath.row]
            musicVC.songVC = MvC
            musicVC.playerExists = true
            musicVC.arrayPos = indexPath.row
            populateNowPlayBar(url: MvC.url)
        
        do{
            musicVC.player = try AVAudioPlayer(contentsOf: userData.songLibrary[indexPath.row])}
        catch{print("Song does not exist.")}
        
        musicVC.player?.prepareToPlay()
        
        musicVC.player?.play()
    }
    
        self.navigationController?.pushViewController(MvC, animated: true)
        
        
    }
    
    
    
    @IBAction func nowPlaying(_ sender: Any) {
         show(musicVC.songVC, sender: self)
    }
    
    
    
    
    
    func getArtist(songURL: URL) -> String
    {
        var theArtist: String = ""
        
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
    
    func getTitle(songURL: URL) -> String
    {
        var theTitle: String = ""
        
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
    
    func getImage(songURL: URL) -> UIImage
    {
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


    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Console.text = "Next"
    }
    
    func populateNowPlayBar(url: URL){
        nowPlayingBar.isHidden = false
        artworkPlaying.image = getImage(songURL: url)
        titlePlaying.text = getTitle(songURL: url)
        artistPlaying.text = getArtist(songURL: url)
        
    }
    


}

