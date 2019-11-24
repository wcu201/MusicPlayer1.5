//
//  MainTabBarController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 9/1/19.
//  Copyright © 2019 William  Uchegbu. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    //let bar = UIToolbar()
    var nowPlayingBar: UIView?
    
    //var currentlyPlaying: CurrentlyPlayingView!
    static let maxHeight = 100
    static let minHeight = 49
    static var tabbarHeight = maxHeight
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //nowPlayingBar = createNowPlayingBar()
        //self.view.addSubview(nowPlayingBar!)
        
        /*
        tabBar.becomeFirstResponder()
        
        //let reset = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: nil)
        //bar.items = [reset]
        //bar.sizeToFit()
        nowPlayingBar = createNowPlayingBar()
        //self.view.addSubview(tabBar)
        tabBar.addSubview(nowPlayingBar!)
        addConstraints()
        //print("nowplaying frame: ", nowPlayingBar?.frame)
        print(0)*/
        // Do any additional setup after loading the view.
    }
    
 
    
    func createNowPlayingBar()->UIView{
        let bar = UIView(frame: CGRect(x: 0, y: self.tabBar.frame.minY-83, width: self.tabBar.frame.width, height: self.tabBar.frame.height))
        bar.backgroundColor = UIColor.white
        let playPauseBTN = UIButton.init(type: .system)
        playPauseBTN.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_play_circle_filled_white_black_48pt"), for: .normal)
        playPauseBTN.clipsToBounds = true
        bar.addSubview(playPauseBTN)
        /*
        let bar = UIView(frame: CGRect(x: 0, y: -100, width: self.view.frame.width, height: self.view.frame.height))
        let artwork = UIImageView(image: UIImage(named: "album-cover-placeholder-light"))
        let backgroundArtwork = UIImageView(image: UIImage(named: "album-cover-placeholder-light"))
        let filterView = UIView()
        let title = UILabel()
        let artist = UILabel()
        let playPauseBTN = UIButton.init(type: .system)
        playPauseBTN.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        
        bar.sizeToFit()
        backgroundArtwork.contentMode = .scaleAspectFill
        backgroundArtwork.clipsToBounds = true
        filterView.backgroundColor = UIColor.black
        filterView.alpha = 0.75
        playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_play_circle_filled_white_black_48pt"), for: .normal)
        //playPauseBTN.setTitle("A", for: .normal)
        
        title.text = "Song"
        title.textColor = UIColor.white
        artist.text = "Artist"
        artist.textColor = UIColor(red: 206.0/255.0, green: 24.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        artist.font = UIFont(name: "System", size: 12.0)
        bar.backgroundColor = UIColor.white
        /*
        bar.addSubview(backgroundArtwork)
        bar.addSubview(filterView)
        bar.addSubview(artwork)
        
        bar.addSubview(title)
        bar.addSubview(artist)*/
        bar.addSubview(playPauseBTN)
        
        let test2 = UIButton.init(type: .system)
        test2.frame = CGRect(x: 160, y: 0, width: 100, height: 50)
        test2.setTitle("testing", for: .normal)
        bar.addSubview(test2)
        test2.addTarget(self, action: #selector(self.press), for: .touchUpInside)
        
        playPauseBTN.translatesAutoresizingMaskIntoConstraints = false
        
        let playPauseBTNTrailingAnchor = NSLayoutConstraint(item: playPauseBTN, attribute: .trailing, relatedBy: .equal, toItem: bar, attribute: .trailing, multiplier: 1, constant: -8)
        let playPauseBTNVerticalAnchor = NSLayoutConstraint(item: playPauseBTN, attribute: .centerY, relatedBy: .equal, toItem: bar, attribute: .centerY, multiplier: 1, constant: 0)
        let playPauseBTNHeightAnchor = NSLayoutConstraint(item: playPauseBTN, attribute: .height, relatedBy: .equal, toItem: bar, attribute: .height, multiplier: 0.5, constant: 0)
        let playPauseBTNAspectRatio = NSLayoutConstraint(item: playPauseBTN, attribute: .width, relatedBy: .equal, toItem: playPauseBTN, attribute: .height, multiplier: 1, constant: 0)
        */
        //bar.addConstraints([playPauseBTNAspectRatio, playPauseBTNHeightAnchor, playPauseBTNTrailingAnchor, playPauseBTNVerticalAnchor])
        
        /*
        artwork.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        artist.translatesAutoresizingMaskIntoConstraints = false
        backgroundArtwork.translatesAutoresizingMaskIntoConstraints = false
        playPauseBTN.translatesAutoresizingMaskIntoConstraints = false
        filterView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let backgroundArtworkLeadingAnchor = NSLayoutConstraint(item: backgroundArtwork, attribute: .leading, relatedBy: .equal, toItem: bar, attribute: .leading, multiplier: 1, constant: 0)
        let backgroundArtworkBottomAnchor = NSLayoutConstraint(item: backgroundArtwork, attribute: .bottom, relatedBy: .equal, toItem: bar, attribute: .bottom, multiplier: 1, constant: 0)
        let backgroundArtworkTopAnchor = NSLayoutConstraint(item: backgroundArtwork, attribute: .top, relatedBy: .equal, toItem: bar, attribute: .top, multiplier: 1, constant: 0)
        let backgroundArtworkTrailing = NSLayoutConstraint(item: backgroundArtwork, attribute: .trailing, relatedBy: .equal, toItem: bar, attribute: .trailing, multiplier: 1, constant: 0)
        
        let filterViewLeadingAnchor = NSLayoutConstraint(item: filterView, attribute: .leading, relatedBy: .equal, toItem: bar, attribute: .leading, multiplier: 1, constant: 0)
        let filterViewBottomAnchor = NSLayoutConstraint(item: filterView, attribute: .bottom, relatedBy: .equal, toItem: bar, attribute: .bottom, multiplier: 1, constant: 0)
        let filterViewTopAnchor = NSLayoutConstraint(item: filterView, attribute: .top, relatedBy: .equal, toItem: bar, attribute: .top, multiplier: 1, constant: 0)
        let filterViewTrailingAnchor = NSLayoutConstraint(item: filterView, attribute: .trailing, relatedBy: .equal, toItem: bar, attribute: .trailing, multiplier: 1, constant: 0)
        
        let artworkLeadingAnchor = NSLayoutConstraint(item: artwork, attribute: .leading, relatedBy: .equal, toItem: bar, attribute: .leading, multiplier: 1, constant: 0)
        let artworkBottomAnchor = NSLayoutConstraint(item: artwork, attribute: .bottom, relatedBy: .equal, toItem: bar, attribute: .bottom, multiplier: 1, constant: 0)
        let artworkTopAnchor = NSLayoutConstraint(item: artwork, attribute: .top, relatedBy: .equal, toItem: bar, attribute: .top, multiplier: 1, constant: 0)
        let artworkAspectRatio = NSLayoutConstraint(item: artwork, attribute: .width, relatedBy: .equal, toItem: bar, attribute: .height, multiplier: 1, constant: 0)
        
        
        let playPauseBTNTrailingAnchor = NSLayoutConstraint(item: playPauseBTN, attribute: .trailing, relatedBy: .equal, toItem: bar, attribute: .trailing, multiplier: 1, constant: -8)
        let playPauseBTNVerticalAnchor = NSLayoutConstraint(item: playPauseBTN, attribute: .centerY, relatedBy: .equal, toItem: bar, attribute: .centerY, multiplier: 1, constant: 0)
        let playPauseBTNHeightAnchor = NSLayoutConstraint(item: playPauseBTN, attribute: .height, relatedBy: .equal, toItem: bar, attribute: .height, multiplier: 0.5, constant: 0)
        let playPauseBTNAspectRatio = NSLayoutConstraint(item: playPauseBTN, attribute: .width, relatedBy: .equal, toItem: playPauseBTN, attribute: .height, multiplier: 1, constant: 0)
        
        let titleLeadingAnchor = NSLayoutConstraint(item: title, attribute: .leading, relatedBy: .equal, toItem: artwork, attribute: .trailing, multiplier: 1, constant: 16)
        let titleVerticalAnchor = NSLayoutConstraint(item: title, attribute: .centerY, relatedBy: .equal, toItem: bar, attribute: .centerY, multiplier: 0.75, constant: 0)
        let titleTrailingAnchor = NSLayoutConstraint(item: title, attribute: .trailing, relatedBy: .equal, toItem: playPauseBTN, attribute: .leading, multiplier: 1, constant: -8)
        
        let artistLeadingAnchor = NSLayoutConstraint(item: artist, attribute: .leading, relatedBy: .equal, toItem: artwork, attribute: .trailing, multiplier: 1, constant: 16)
        let artistVerticalAnchor = NSLayoutConstraint(item: artist, attribute: .centerY, relatedBy: .equal, toItem: bar, attribute: .centerY, multiplier: 1.5, constant: 0)
        let artistTrailingAnchor = NSLayoutConstraint(item: artist, attribute: .trailing, relatedBy: .equal, toItem: playPauseBTN, attribute: .leading, multiplier: 1, constant: -8)
        
        
        bar.addConstraints([artworkTopAnchor, artworkAspectRatio, artworkBottomAnchor, artworkLeadingAnchor, backgroundArtworkTrailing, backgroundArtworkTopAnchor, backgroundArtworkBottomAnchor, backgroundArtworkLeadingAnchor, filterViewTrailingAnchor, filterViewTopAnchor, filterViewBottomAnchor, filterViewLeadingAnchor,playPauseBTNAspectRatio, playPauseBTNTrailingAnchor, playPauseBTNHeightAnchor, playPauseBTNVerticalAnchor, titleLeadingAnchor, titleTrailingAnchor, titleVerticalAnchor, artistTrailingAnchor, artistLeadingAnchor, artistVerticalAnchor])*/
        return bar
    }
    
    @objc func press(){
        print("tapped")
    }
    
    func addConstraints(){
        
        /*nowPlayingBar?.translatesAutoresizingMaskIntoConstraints = false
        
        let leadingAnchor = NSLayoutConstraint(item: nowPlayingBar, attribute: .leading, relatedBy: .equal, toItem: tabBar, attribute: .leading, multiplier: 1, constant: 0)
        let trailingAnchor = NSLayoutConstraint(item: nowPlayingBar, attribute: .trailing, relatedBy: .equal, toItem: tabBar, attribute: .trailing, multiplier: 1, constant: 0)
        let bottomAnchor = NSLayoutConstraint(item: nowPlayingBar, attribute: .bottom, relatedBy: .equal, toItem: tabBar, attribute: .top, multiplier: 1, constant: 0)
        let heightAnchor = NSLayoutConstraint(item: nowPlayingBar, attribute: .height, relatedBy: .equal, toItem: tabBar, attribute: .height, multiplier: 0.75, constant: 0)
        
        self.view.addConstraints([leadingAnchor, trailingAnchor, bottomAnchor, heightAnchor])*/
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
