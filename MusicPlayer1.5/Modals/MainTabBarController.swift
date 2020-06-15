//
//  MainTabBarController.swift
//  MusicPlayer1.5
//
//  Created by William Uchegbu on 9/1/19.
//  Copyright © 2019 William Uchegbu. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UIGestureRecognizerDelegate {

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
    let controller = MusicController()
    
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
        let singleFingerTap = UITapGestureRecognizer(target: self, action: #selector(barIsTapped))
        MainTabBarController.nowPlayingBar.addGestureRecognizer(singleFingerTap)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(populateNowPlayBar),
                                               name: .songChanged,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeToPlayBTN),
                                               name: .songPaused,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeToPauseBTN),
                                               name: .songPlayed,
                                               object: nil)
        
    }
    
    @objc func barIsTapped(){
        guard let vc = appDelegate.playerVC else {
            return
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func playPause(){
        if !(AppDelegate.sharedPlayer.isPlaying) {
            controller.playSong()
        }
        else {
            controller.pauseSong()
        }
    }
    
    @objc func changeToPlayBTN(){
        MainTabBarController.playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_play_circle_filled_white_black_48pt"), for: .normal)
    }
    
    @objc func changeToPauseBTN(){
        MainTabBarController.playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_pause_circle_filled_black_48pt"), for: .normal)
    }
    
    @objc func populateNowPlayBar(){
        if let url = AppDelegate.sharedPlayer.url {
            // Workaround
            if noBar {
                MainTabBarController.nowPlayingBar.isHidden = false
                noBar = false
                
                // Here is where I need to change the view contraints to always be above the bar
//                let transitionView = self.view.subviews[0]
//                transitionView.translatesAutoresizingMaskIntoConstraints = false
//                self.view.addConstraints([
//                    NSLayoutConstraint(item: transitionView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
//                    NSLayoutConstraint(item: transitionView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
//                    NSLayoutConstraint(item: transitionView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0),
//                    NSLayoutConstraint(item: transitionView, attribute: .bottom, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .top, multiplier: 1, constant: 0),
//                ])
                let constraint = NSLayoutConstraint(item: MainTabBarController.nowPlayingBar, attribute: .top, relatedBy: .equal, toItem: tabBar, attribute: .top, multiplier: 1, constant: -60)
                self.view.removeConstraint(constraint)
                print(0)
                self.view.updateConstraints()
            }
            
            artwork.image = getImage(songURL: url)
            backgroundArtwork.image = getImage(songURL: url)
            songTitle.text = getTitle(songURL: url)
            songArtist.text = getArtist(songURL: url)
        }
        else {
            noBar = true
            MainTabBarController.nowPlayingBar.isHidden = true
        }
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
            NSLayoutConstraint(item: MainTabBarController.playPauseBTN, attribute: .height, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .height, multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: MainTabBarController.playPauseBTN, attribute: .width, relatedBy: .equal, toItem: MainTabBarController.playPauseBTN, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: MainTabBarController.playPauseBTN, attribute: .centerY, relatedBy: .equal, toItem: MainTabBarController.nowPlayingBar, attribute: .centerY, multiplier: 1, constant: 0),
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
