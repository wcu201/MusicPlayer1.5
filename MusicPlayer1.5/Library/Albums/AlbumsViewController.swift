//
//  AlbumsViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/24/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit
import AVKit

class AlbumsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var albumDictionary: [String : [URL]] {
        var dict = [String: [URL]]()
        
        for song in userData.downloadLibrary {
            if dict[getAlbum(songURL: song)] != nil {
                dict[getAlbum(songURL: song)]?.append(song)
            }
            else {
                dict[getAlbum(songURL: song)] = [song]
            }
        }
        
        return dict
    }
    
    var selectedLibrary = [URL]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if albumDictionary.count % 2 == 0 {
            return albumDictionary.count/2
        }
        else{
            return albumDictionary.count/2 + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let albumKeys = Array(albumDictionary.keys)
        //print("Keys: ", albumKeys)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell") as! albumsTableViewCell
        cell.album1Art.image = getImage(songURL: albumDictionary[albumKeys[indexPath.row * 2]]![0])
        cell.title1.text = getAlbum(songURL: albumDictionary[albumKeys[indexPath.row * 2]]![0])
        cell.artist1.text = getArtist(songURL: albumDictionary[albumKeys[indexPath.row * 2]]![0])
        
        cell.album1Art.isUserInteractionEnabled = true
        cell.album1Art.restorationIdentifier = albumKeys[indexPath.row * 2]
        let tapGestureRecognizer = UIGestureRecognizer(target: self, action: #selector(
        self.showSongs))
        cell.album1Art.addGestureRecognizer(tapGestureRecognizer)
        
        
        if (indexPath.row*2+1 < albumDictionary.count) {
            cell.album2Art.image = getImage(songURL: albumDictionary[albumKeys[indexPath.row * 2 + 1]]![0])
            cell.title2.text = getAlbum(songURL: albumDictionary[albumKeys[indexPath.row * 2 + 1]]![0])
            cell.artist2.text = getArtist(songURL: albumDictionary[albumKeys[indexPath.row * 2 + 1]]![0])
            
            cell.album2Art.isUserInteractionEnabled = true
            cell.album2Art.restorationIdentifier = albumKeys[indexPath.row * 2 + 1]
            let tapGestureRecognizer = UIGestureRecognizer(target: self, action: #selector(self.showSongs))
            cell.album2Art.addGestureRecognizer(tapGestureRecognizer)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //print("Album: ", albumKeys)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getAlbum(songURL: URL) -> String {
        var album = String()
        
        let item = AVPlayerItem(url: songURL)
        let metadata = item.asset.metadata
        
        for theItem in metadata {
            if theItem.commonKey == nil {continue}
            if let key = theItem.commonKey, let value = theItem.value{
                if key == "albumName"{
                    album = value as! String
                }
            }
        }
        
        if album == "" || album.isEmpty {
            album = "Unknown Album"
        }
        return album
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
    
    @objc func showSongs(/*sender: UIImageView*/) {
        print("Picture Pressed")
        //selectedLibrary = albumDictionary[sender.restorationIdentifier!]!
        //performSegue(withIdentifier: "showAlbumSongs", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? ViewController
        vc?.currentLibray = selectedLibrary
    }
}
