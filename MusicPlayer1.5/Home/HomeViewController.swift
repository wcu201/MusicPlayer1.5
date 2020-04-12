//
//  HomeViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 3/30/19.
//  Copyright © 2019 William  Uchegbu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var nowPlayingBar: UIView!
    
    @IBOutlet weak var artworkPlaying: UIImageView!
    
    @IBOutlet weak var backgroundArtworkPlaying: UIImageView!
    @IBOutlet weak var artistPlaying: UILabel!
    @IBOutlet weak var titlePlaying: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var recentlyAddedCollection: UICollectionView!
    
    @IBOutlet weak var playPauseBTN: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var test: ViewController?
    
    
    let sections = ["Songs", "Artists", "Albums", "Playlists"]
    let sectionImages = [#imageLiteral(resourceName: "outline_library_music_black_36dp"),#imageLiteral(resourceName: "baseline_recent_actors_black_48dp"),#imageLiteral(resourceName: "baseline_album_black_36dp"),#imageLiteral(resourceName: "outline_playlist_play_black_36dp")]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
            case collection:
                return sections.count
            case recentlyAddedCollection:
                if appDelegate.downloadLibrary.count >= 5 {return 5}
                else {return appDelegate.downloadLibrary.count}
            default:
                return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case collection:
            let cell = collection.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCollectionViewCell
            //cell.layer.cornerRadius = 15
            
            let img = resizeImage(image: sectionImages[indexPath.row], targetSize: CGSize(width: 20, height: 20))
            cell.icon.image = img
            cell.icon.image = img.withRenderingMode(.alwaysTemplate)
            cell.icon.tintColor = UIColor.white
            cell.label.text = sections[indexPath.row]
            cell.backgroundColor = UIColor(red: 41/255, green: 45/255, blue: 51/255, alpha: 1.0)
            return cell
        case recentlyAddedCollection:
            let cell = recentlyAddedCollection.dequeueReusableCell(withReuseIdentifier: "recentlyAddedCell", for: indexPath) as! RecentlyAddedCollectionViewCell
            cell.artwork.image = getImage(songURL: appDelegate.downloadLibrary[appDelegate.downloadLibrary.count-indexPath.row-1])
            return cell
        default:
            return UICollectionViewCell(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
            case collection:
                switch indexPath.row {
                    case 0:
                        if let vc = appDelegate.songsVC {
                            //self.navigationController?.pushViewController(vc, animated: true)
                            show(vc, sender: self)
                        }
                        else {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "songs") as! ViewController
                            appDelegate.selectedLibrary = appDelegate.downloadLibrary
                            appDelegate.songsVC = vc
                            self.navigationController?.pushViewController(vc, animated: true)
                            //self.performSegue(withIdentifier: "goToSongs", sender: self)
                    }
                    case 1:
                        self.performSegue(withIdentifier: "goToArtists", sender: self)
                    case 2:
                        self.performSegue(withIdentifier: "goToAlbums", sender: self)
                    case 3:
                        self.performSegue(withIdentifier: "goToPlaylists", sender: self)
                    default:
                        break
                }
            case recentlyAddedCollection:
                break
            default:
                break
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard appDelegate.musicPlaying else {
            print("no music")
            return
        }
        
        //Deprecated trying to have this get handled by the notification center. Once implemented I can get rid of viewWillAppear until I needd it again
        //self.populateNowPlayBar(url: appDelegate.songPlaying!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.delegate = self
        collection.dataSource = self
        
        recentlyAddedCollection.delegate = self
        recentlyAddedCollection.dataSource = self
        
        refresh(v: container)
        collection.backgroundColor = UIColor.clear
        recentlyAddedCollection.backgroundColor = UIColor.clear
        
        //NotificationCenter.default.addObserver(self, selector: #selector(populateNowPlayBar), name: .songChanged, object: nil)
        // Do any additional setup after loading the view.
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "goToSongs":
                appDelegate.selectedLibrary = appDelegate.downloadLibrary
            default:
                break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func populateNowPlayBar(){
        let url = AppDelegate.sharedPlayer.url!
        nowPlayingBar.isHidden = false
        artworkPlaying.image = getImage(songURL: url)
        backgroundArtworkPlaying.image = getImage(songURL: url)
        titlePlaying.text = getTitle(songURL: url)
        artistPlaying.text = getArtist(songURL: url)
        
        
        //Will need another notification that updates the play pause buttons as well
        //if AppDelegate.sharedPlayer.isPlaying {playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_pause_circle_filled_black_48pt"), for: .normal)}
        //else {playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_play_circle_filled_white_black_48pt"), for: .normal)}
    }
    
    @IBAction func playPauseMusic(_ sender: Any) {
        if AppDelegate.sharedPlayer.isPlaying{
            AppDelegate.sharedPlayer.pause()
            playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_play_circle_filled_white_black_48pt"), for: .normal)
        }
        else{
            AppDelegate.sharedPlayer.play()
            playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_pause_circle_filled_black_48pt"), for: .normal)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
