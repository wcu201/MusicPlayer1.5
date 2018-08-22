//
//  Objects.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/26/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import Foundation
import AVKit

struct musicVC{
    static var nav = UINavigationController()
    static var player: AVAudioPlayer?
    static var songPlaying: URL?
    static var allSongsVC = ViewController()
    static var songVC = MusicViewController()
    static var arrayPos = Int()
    static var playerExists: Bool = false
    static var nowPlayHidden: Bool = true
    static var isShuffled: Bool = false
}

struct userData{
    static var songLibrary: [URL] = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: "Music Library")!
    static var downloadLibrary: [URL] {
        var downloads = [URL]()
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for song in fileURLs {
                downloads.append(song)
            }
        }
        catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        
        /*
         print("Path To Delete: ", downloads[1].path)
         do {
         try FileManager.default.removeItem(atPath: downloads[1].path)
         }catch{print(error)}*/
        return downloads
        //return downloads.sorted(by: {self.getTitle($0.) < getTitle($1)})
    }
    static var shuffledLibrary = [URL]()
    static var filteredLibrary = [URL]()
    static var filteredPositions = [Int]()
    static var filteredMap = [Int: URL]()
    
}

func getArtist(songURL: URL) -> String {
    var theArtist: String = "Unknown Artist"
    
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
