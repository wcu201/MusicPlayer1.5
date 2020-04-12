//
//  MainTabBarController.swift
//  MusicPlayer1.5
//
//  Created by William Uchegbu on 9/1/19.
//  Copyright © 2019 William Uchegbu. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    static var nowPlayingBar: UIView = {
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    var backgroundArtwork: UIImageView = {
        let background = UIImageView()
        background.clipsToBounds = true
        background.contentMode = .scaleAspectFill
        background.image = #imageLiteral(resourceName: "album-cover-placeholder-light")
        background.translatesAutoresizingMaskIntoConstraints = false
        return background
    }()
    
    var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let blur = UIVisualEffectView(effect: effect)
        blur.translatesAutoresizingMaskIntoConstraints = false
        return blur
    }()
    
    var artwork: UIImageView = {
        let art = UIImageView()
        art.image = #imageLiteral(resourceName: "album-cover-placeholder-light")
        art.translatesAutoresizingMaskIntoConstraints = false
        return art
    }()
    
    static var playPauseBTN: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "baseline_pause_circle_filled_black_48pt"), for: .normal)
        button.tintColor = mainRed
        button.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var songTitle: UILabel = {
        let title = UILabel()
        title.textColor = .white
        title.font = UIFont(name: "Avenir Book", size: 17.0)
        title.text = "Title"
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    var songArtist: UILabel = {
        let artist = UILabel()
        artist.textColor = mainRed
        artist.font = UIFont(name: "Avenir Book", size: 12.0)
        artist.text = "Artist"
        artist.translatesAutoresizingMaskIntoConstraints = false
        return artist
    }()
    
    var noBar = true
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.insertSubview(MainTabBarController.nowPlayingBar, aboveSubview: tabBar)
        MainTabBarController.nowPlayingBar.addSubview(backgroundArtwork)
        MainTabBarController.nowPlayingBar.addSubview(blurView)
        MainTabBarController.nowPlayingBar.addSubview(artwork)
        MainTabBarController.nowPlayingBar.addSubview(MainTabBarController.playPauseBTN)
        MainTabBarController.nowPlayingBar.addSubview(songTitle)
        MainTabBarController.nowPlayingBar.addSubview(songArtist)
        
        setupLayout()
        MainTabBarController.nowPlayingBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(populateNowPlayBar), name: .songChanged, object: nil)
    }
    
    @objc func playPause(){
        if !(AppDelegate.sharedPlayer.isPlaying) {
            AppDelegate.sharedPlayer.play()
            MainTabBarController.playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_pause_circle_filled_black_48pt"), for: .normal)
            appDelegate.playerVC?.playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
        }
            
        else {
            AppDelegate.sharedPlayer.pause()
            MainTabBarController.playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_play_circle_filled_white_black_48pt"), for: .normal)
            appDelegate.playerVC?.playPauseButton.setImage(#imageLiteral(resourceName: "play_arrow_white_54x54"), for: .normal)
        }
    }
    
    @objc func populateNowPlayBar(){
        let url = AppDelegate.sharedPlayer.url!
        
        // Workaround
        if noBar {
            MainTabBarController.nowPlayingBar.isHidden = false
            noBar = false
        }
        
        artwork.image = getImage(songURL: url)
        backgroundArtwork.image = getImage(songURL: url)
        songTitle.text = getTitle(songURL: url)
        songArtist.text = getArtist(songURL: url)
    }
    
    private func setupLayout(){
        // Now Playing Bar
        self.view.addConstraints([
            NSLayoutConstraint(item: MainTabBarController.nowPlayingBar, attribute: .leading, relatedBy: .equal, toItem: tabBar, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: MainTabBarController.nowPlayingBar, attribute: .trailing, relatedBy: .equal, toItem: tabBar, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: MainTabBarController.nowPlayingBar, attribute: .top, relatedBy: .equal, toItem: tabBar, attribute: .top, multiplier: 1, constant: -60),
            NSLayoutConstraint(item: MainTabBarController.nowPlayingBar, attribute: .bottom, relatedBy: .equal, toItem: tabBar, attribute: .top, multiplier: 1, constant: 0)
            ])
        
        // Background
        self.view.addConstraints([
            NSLayoutConstraint(item: backgroundArtwork, attribute: .leading, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundArtwork, attribute: .trailing, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundArtwork, attribute: .top, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundArtwork, attribute: .bottom, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        // Blur
        self.view.addConstraints([
            NSLayoutConstraint(item: blurView, attribute: .leading, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurView, attribute: .trailing, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurView, attribute: .top, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurView, attribute: .bottom, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        // Artwork
        self.view.addConstraints([
            NSLayoutConstraint(item: artwork, attribute: .leading, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: artwork, attribute: .height, relatedBy: .equal, toItem: artwork, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: artwork, attribute: .top, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: artwork, attribute: .bottom, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        // Play/Pause Button
        self.view.addConstraints([
            NSLayoutConstraint(item: MainTabBarController.playPauseBTN, attribute: .trailing, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .trailing, multiplier: 1, constant: -8),
            NSLayoutConstraint(item: MainTabBarController.playPauseBTN, attribute: .height, relatedBy: .equal, toItem: MainTabBarController.playPauseBTN, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: MainTabBarController.playPauseBTN, attribute: .top, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .top, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: MainTabBarController.playPauseBTN, attribute: .bottom, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .bottom, multiplier: 1, constant: -8)
            ])
        
        // Title
        self.view.addConstraints([
            NSLayoutConstraint(item: songTitle, attribute: .leading, relatedBy: .equal, toItem: artwork, attribute: .trailing, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: songTitle, attribute: .trailing, relatedBy: .equal, toItem: MainTabBarController.playPauseBTN, attribute: .leading, multiplier: 1, constant: -8),
            NSLayoutConstraint(item: songTitle, attribute: .top, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .top, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: songTitle, attribute: .height, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .height, multiplier: 0.5, constant: 0)
            ])
        
        // Artist
        self.view.addConstraints([
            NSLayoutConstraint(item: songArtist, attribute: .leading, relatedBy: .equal, toItem: artwork, attribute: .trailing, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: songArtist, attribute: .trailing, relatedBy: .equal, toItem: MainTabBarController.playPauseBTN, attribute: .leading, multiplier: 1, constant: -8),
            NSLayoutConstraint(item: songArtist, attribute: .top, relatedBy: .equal, toItem: songTitle, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: songArtist, attribute: .bottom, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .bottom, multiplier: 1, constant: -8)
            ])
        
        
        
    }

}
