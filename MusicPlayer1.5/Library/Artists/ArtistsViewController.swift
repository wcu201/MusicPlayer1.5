//
//  ArtistsViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/24/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit
import AVKit

class ArtistsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var artistDictionary: [String : [URL]] {
        var dict = [String: [URL]]()
        
        for song in userData.downloadLibrary {
            if dict[getArtist(songURL: song)] != nil {
                dict[getArtist(songURL: song)]?.append(song)
            }
            else {
                dict[getArtist(songURL: song)] = [song]
            }
        }
        
        return dict
    }
    
    var selectedLibrary = [URL]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return artistDictionary.count
        return appDelegate.artistsLibraries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //var keys = Array(artistDictionary.keys)
        var keys = Array(appDelegate.artistsLibraries.keys)
        keys.sort()
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistCell")
        cell?.textLabel?.text = keys[indexPath.row]
        cell?.textLabel?.textColor = UIColor(red: 206.0/255.0, green: 24.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var keys = Array(artistDictionary.keys)
        keys.sort()
        selectedLibrary = artistDictionary[keys[indexPath.row]]!
        performSegue(withIdentifier: "showSongs", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        appDelegate.selectedLibrary = selectedLibrary
        //let vc = segue.destination as? ViewController
        //vc?.currentLibray = selectedLibrary
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getArtist(songURL: URL) -> String {
        var theArtist: String = "Unknow Artist"
        
        let item = AVPlayerItem(url: songURL)
        let metadata = item.asset.metadata
        
        for theItem in metadata {
            if theItem.commonKey == nil { continue }
            if let key = theItem.commonKey, let value = theItem.value {
                if key.rawValue == "artist"
                {theArtist = value as! String}
            }
        }
        return theArtist
    }

}
