//
//  MusicPlayerViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 5/9/20.
//  Copyright © 2020 William  Uchegbu. All rights reserved.
//

import Foundation
import UIKit

class MusicPlayerViewController: UIViewController {
    var songURL: URL?
    var artworkImage = #imageLiteral(resourceName: "album-cover-placeholder-light")
    var trackLabel = UILabel()
    var mainArtwork = UIImageView()
    var backgroundArtwork = UIImageView()
    var blurView = UIVisualEffectView()
    var musicProgressStackView = UIStackView()
    var timePassed = UILabel()
    var timeRemaining = UILabel()
    var musicProgressSlider = UISlider()
    var songTitle =  UILabel()
    var songArtist = UILabel()
    var controls = UIStackView()
    var playPauseBTN = UIButton()
    var skipBackBTN = UIButton()
    var skipForwardBTN = UIButton()
    var shuffleBTN = UIButton()
    var reapeatBTN = UIButton()
    var volumeStack = UIStackView()
    var volumeLowBTN = UIButton()
    var volumeHighBTN = UIButton()
    var volumeSlider = UISlider()
    let controller = MusicController()
    
    init(songURL: URL){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.songURL = songURL
        
        self.artworkImage = getImage(songURL: songURL)
        self.songTitle.text = getTitle(songURL: songURL)
        self.songArtist.text = getArtist(songURL: songURL)
        backgroundArtwork.image = artworkImage
        mainArtwork.image = artworkImage
        
        super.init(nibName: nil, bundle: nil)
        //self.trackLabel.text = "\(delegate.arrayPos+1) of \(delegate.selectedLibrary.count)"
        self.trackLabel.text = "\(delegate.arrayPos+1) of \(delegate.currentPlaylist.count)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        //Should initialize with a URL
        setupUI()
        addConstraints()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setup),
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(highlightShuffleBTN),
                                               name: .shuffleOn,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(unhighlightShuffleBTN),
                                               name: .shuffleOff,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTrackLabel),
                                               name: .arrayPosChanged, 
                                               object: nil)
        
        
    }
    
    @objc func setup(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        //self.songURL = delegate.selectedLibrary[delegate.arrayPos]
        self.songURL = (delegate.currentPlaylist[delegate.arrayPos] as! URL)
        
        guard let url = songURL else {return}
        artworkImage = getImage(songURL: url)
        songTitle.text = getTitle(songURL: url)
        songArtist.text = getArtist(songURL: url)
        backgroundArtwork.image = artworkImage
        mainArtwork.image = artworkImage
        
        //self.trackLabel.text = "\(delegate.arrayPos+1) of \(delegate.selectedLibrary.count)"
        //self.trackLabel.text = "\(delegate.arrayPos+1) of \(delegate.currentPlaylist.count)"
    }
    
    @objc func changeToPlayBTN(){
        if #available(iOS 13.0, *) {
            let largeConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
            playPauseBTN.setImage(UIImage(systemName: "play.fill", withConfiguration: largeConfig), for: .normal)
        }
    }
    
    @objc func changeToPauseBTN(){
        if #available(iOS 13.0, *) {
            let largeConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
            playPauseBTN.setImage(UIImage(systemName: "pause.fill", withConfiguration: largeConfig), for: .normal)
        }
    }
    
    @objc func highlightShuffleBTN(){
        shuffleBTN.tintColor = mainRed
    }
    
    @objc func unhighlightShuffleBTN(){
        shuffleBTN.tintColor = .white
    }
    
    @objc func updateTrackLabel(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.trackLabel.text = "\(delegate.arrayPos+1) of \(delegate.currentPlaylist.count)"
    }
    
    @objc func playPause(){
        if AppDelegate.sharedPlayer.isPlaying {
            controller.pauseSong()
        }
        else {
            controller.playSong()
            }
    }
    
    @objc func skipBack(){
        controller.skipBack()
    }
    
    @objc func skipForward(){
        MusicController.nextSong()
    }
    
    @objc func shuffle(){
        MusicController().shuffle()
    }
    
    @objc func repeatAction(){
    }
    
    func setupUI(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        //Background Artwork
        backgroundArtwork.contentMode = .scaleAspectFill
        backgroundArtwork.clipsToBounds = true
        backgroundArtwork.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(backgroundArtwork)
        
        //Blur
        let effect = UIBlurEffect(style: .dark)
        blurView = UIVisualEffectView(effect: effect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(blurView)
        
        //Track Label
        //trackLabel.text = "\(delegate.arrayPos+1) of \(delegate.selectedLibrary.count)"
        self.trackLabel.text = "\(delegate.arrayPos+1) of \(delegate.currentPlaylist.count)"
        trackLabel.font = UIFont(name: "Avenir Book", size: 25.0)
        trackLabel.textColor = mainRed
        trackLabel.textAlignment = .center
        trackLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(trackLabel)
        
        //Main Artwork
        mainArtwork.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mainArtwork)
        
        //Music Progress Stack
        timePassed.text = "0:00"
        timeRemaining.text = "0:00"
        timePassed.font = UIFont.systemFont(ofSize: 8)
        timeRemaining.font = UIFont.systemFont(ofSize: 8)
        timePassed.textAlignment = .center
        timeRemaining.textAlignment = .center
        timePassed.textColor = .white
        timeRemaining.textColor = .white
        musicProgressSlider.tintColor = mainRed
        musicProgressSlider.setThumbImage(resizeImage(
                image: UIImage(named: "custom_thumb")!,
                targetSize: CGSize(
                    width: 20,
                    height: 20)),
            for: .normal)
        
        musicProgressStackView.axis = .horizontal
        musicProgressStackView.distribution = .equalSpacing
        musicProgressStackView.translatesAutoresizingMaskIntoConstraints = false
        musicProgressStackView.addArrangedSubview(timePassed)
        musicProgressStackView.addArrangedSubview(musicProgressSlider)
        musicProgressStackView.addArrangedSubview(timeRemaining)
        self.view.addSubview(musicProgressStackView)
        
        //Song Title
        songTitle.textColor = .white
        songTitle.font = UIFont(name: "Avenir Book", size: 25.0)
        songTitle.textAlignment = .center
        songTitle.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(songTitle)
        
        //Song Artist
        songArtist.textColor = .gray
        songArtist.font = UIFont(name: "Avenir Book", size: 17.0)
        songArtist.textAlignment = .center
        songArtist.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(songArtist)
        
        //Controls Stack
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(textStyle: .title2)
            let largeConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
            
            shuffleBTN.setImage(UIImage(systemName: "shuffle", withConfiguration: config), for: .normal)
            shuffleBTN.tintColor = .white
            shuffleBTN.addTarget(self, action: #selector(shuffle), for: .touchUpInside)
            
            skipBackBTN.setImage(UIImage(systemName: "backward.fill", withConfiguration: config), for: .normal)
            skipBackBTN.tintColor = .white
            skipBackBTN.addTarget(self, action: #selector(skipBack), for: .touchUpInside)
            
            playPauseBTN.setImage(UIImage(systemName: "pause.fill", withConfiguration: largeConfig), for: .normal)
            playPauseBTN.tintColor = .white
            playPauseBTN.addTarget(self, action: #selector(playPause), for: .touchUpInside)
            
            skipForwardBTN.setImage(UIImage(systemName: "forward.fill", withConfiguration: config), for: .normal)
            skipForwardBTN.tintColor = .white
            skipForwardBTN.addTarget(self, action: #selector(skipForward), for: .touchUpInside)
            
            reapeatBTN.setImage(UIImage(systemName: "repeat", withConfiguration: config), for: .normal)
            reapeatBTN.tintColor = .white
            reapeatBTN.addTarget(self, action: #selector(repeatAction), for: .touchUpInside)
            
        } else {
            playPauseBTN.setImage(UIImage(named: "pause_white_54x54"), for: .normal)
        }
        controls.axis = .horizontal
        controls.distribution = .equalSpacing
        controls.translatesAutoresizingMaskIntoConstraints = false
        controls.addArrangedSubview(shuffleBTN)
        controls.addArrangedSubview(skipBackBTN)
        controls.addArrangedSubview(playPauseBTN)
        controls.addArrangedSubview(skipForwardBTN)
        controls.addArrangedSubview(reapeatBTN)
        self.view.addSubview(controls)
        
        //Volume Slider
        volumeSlider.tintColor = mainRed
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(volumeSlider)
        
        
        
    }
    
    func addConstraints(){
        
        //Background Artwork
        self.view.addConstraints([
            NSLayoutConstraint(item: backgroundArtwork, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundArtwork, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundArtwork, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundArtwork, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        ])
        
        //Blur
        self.view.addConstraints([
            NSLayoutConstraint(item: blurView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        ])
        
        //Track Label
        self.view.addConstraints([
            NSLayoutConstraint(item: trackLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: trackLabel, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: trackLabel, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0),
            //NSLayoutConstraint(item: trackLabel, attribute: .height, relatedBy: .equal, toItem: mainArtwork, attribute: .width, multiplier: 1, constant: 0)
        ])
        
        //Main Artwork
        self.view.addConstraints([
            NSLayoutConstraint(item: mainArtwork, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: mainArtwork, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.65, constant: 0),
            NSLayoutConstraint(item: mainArtwork, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: mainArtwork, attribute: .height, relatedBy: .equal, toItem: mainArtwork, attribute: .width, multiplier: 1, constant: 0)
        ])
        
        //Music Progress Stack
        self.view.addConstraints([
            NSLayoutConstraint(item: musicProgressStackView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: musicProgressStackView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.8, constant: 0),
            NSLayoutConstraint(item: musicProgressStackView, attribute: .top, relatedBy: .equal, toItem: mainArtwork, attribute: .bottom, multiplier: 1, constant: 16),
            //Standard height, no need to set
        ])
        
        //Music Progress Slider
        self.view.addConstraints([
            NSLayoutConstraint(item: musicProgressSlider, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.65, constant: 0),
        ])
        
        //Song Title
        self.view.addConstraints([
            NSLayoutConstraint(item: songTitle, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: songTitle, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -8),
            NSLayoutConstraint(item: songTitle, attribute: .top, relatedBy: .equal, toItem: musicProgressSlider, attribute: .bottom, multiplier: 1, constant: 8),
            //Standard height, no need to set
        ])
        
        //Song Artist
        self.view.addConstraints([
            NSLayoutConstraint(item: songArtist, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: songArtist, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -8),
            NSLayoutConstraint(item: songArtist, attribute: .top, relatedBy: .equal, toItem: songTitle, attribute: .bottom, multiplier: 1, constant: 8),
            //Standard height, no need to set
        ])
        
        //Controls Stack
        self.view.addConstraints([
            NSLayoutConstraint(item: controls, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: controls, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.8, constant: 0),
            NSLayoutConstraint(item: controls, attribute: .top, relatedBy: .equal, toItem: songArtist, attribute: .bottom, multiplier: 1, constant: 16),
        ])
        
        //Volume Slider
        self.view.addConstraints([
            NSLayoutConstraint(item: volumeSlider, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: volumeSlider, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.8, constant: 0),
            NSLayoutConstraint(item: volumeSlider, attribute: .top, relatedBy: .equal, toItem: controls, attribute: .bottom, multiplier: 1, constant: 16),
        ])
        
    }
}
