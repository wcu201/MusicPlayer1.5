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
            if key.rawValue == "artist"
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
            if key.rawValue == "title"
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
            if key.rawValue == "artwork"{
                theImage = UIImage(data: value as! Data)!
            }
        }
    }
    
    
    return theImage
}

//Opens an alert controller that requests a yes or no from the user. If yes is chosen the action parameter is called
func openBoolAlert(title: String, message: String, view: UIViewController, action: @escaping ()->Void) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let yes = UIAlertAction(title: "Yes", style: .destructive, handler: {(myAction) in
        action()
    })
    let no = UIAlertAction(title: "No", style: .default, handler: nil)
    
    alert.addAction(yes)
    alert.addAction(no)
    
    view.present(alert, animated: true, completion: nil)
}

/*
func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 10.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}*/
