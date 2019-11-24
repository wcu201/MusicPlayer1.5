//
//  AlbumsViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/24/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit
import AVKit

class AlbumsViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedLibrary = [URL]()
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
    
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    var currentLibrary = [URL]()
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.appDelegate.albumLibraries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var keys = Array(appDelegate.albumLibraries.keys)
        keys.sort()
        let firstSong = appDelegate.albumLibraries[keys[indexPath.row]]![0]
        let cell = albumsCollectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! AlbumCollectionViewCell
        cell.artist.text = getArtist(songURL: firstSong)
        cell.album.text = getAlbum(songURL: firstSong)
        cell.artwork.image = getImage(songURL: firstSong)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var keys = Array(albumDictionary.keys)
        keys.sort()
        selectedLibrary = albumDictionary[keys[indexPath.row]]!
        
        
        appDelegate.selectedLibrary = selectedLibrary
        let destination: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "songs") as! ViewController
        self.present(destination, animated: true, completion: nil)
        //_ = UIStoryboardSegue(identifier: "showSongs", source: self, destination: ViewController())
        //performSegue(withIdentifier: "showSongs", sender: self)
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
    
    /*
 cell.album2Art.isUserInteractionEnabled = true
 cell.album2Art.restorationIdentifier = albumKeys[indexPath.row * 2 + 1]
 let tapGestureRecognizer = UIGestureRecognizer(target: self, action: #selector(self.showSongs))
 */
    @objc func showSongs(/*sender: UIImageView*/) {
        print("Picture Pressed")
        //selectedLibrary = albumDictionary[sender.restorationIdentifier!]!
        //performSegue(withIdentifier: "showAlbumSongs", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        appDelegate.selectedLibrary = selectedLibrary
    }
}
