//
//  MusicPlayerViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 5/9/20.
//  Copyright © 2020 William  Uchegbu. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import MediaPlayer

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
    var musicTimer: Timer?
    
    init(songURL: URL){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.songURL = songURL
        
        self.artworkImage = getImage(songURL: songURL)
        self.songTitle.text = getTitle(songURL: songURL)
        self.songArtist.text = getArtist(songURL: songURL)
        self.timeRemaining.text = AppDelegate.sharedPlayer.duration.stringFromTimeInterval()
        backgroundArtwork.image = artworkImage
        mainArtwork.image = artworkImage
        
        super.init(nibName: nil, bundle: nil)
        //self.trackLabel.text = "\(delegate.arrayPos+1) of \(delegate.selectedLibrary.count)"
        self.trackLabel.text = "\(delegate.arrayPos+1) of \(delegate.currentPlaylist.count)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateSlider(animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.scheduelTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.stopTimer()
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
                                               selector: #selector(stopTimer),
                                               name: .songPaused,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeToPauseBTN),
                                               name: .songPlayed,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(scheduelTimer),
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateRepeatStatusBTN),
                                               name: .repeatStatusChanged,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeToPauseBTN),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(volumeChanged),
                                               name: NSNotification.Name( "AVSystemController_SystemVolumeDidChangeNotification"),
                                               object: nil)
        
        
    }
    
    func updateSlider(animated: Bool){
            let timeRatio = Float(AppDelegate.sharedPlayer.currentTime/AppDelegate.sharedPlayer.duration)
            self.musicProgressSlider.setValue(timeRatio, animated: animated)
    }

    func updateTimeLabels(){
        let player = AppDelegate.sharedPlayer
        let timePassed = round(Float(player.currentTime))
        let timeRemaining  = round(Float(player.duration)-Float(player.currentTime))
        var seconds = Int(timePassed)%60
        var minutes = Int(timePassed)/60
        if seconds<10 {self.timePassed.text = "\(minutes)"+":"+"0"+"\(seconds)"}
        else {self.timePassed.text = "\(minutes)"+":"+"\(seconds)"}
        seconds = Int(timeRemaining)%60
        minutes = Int(timeRemaining)/60
        if seconds<10{self.timeRemaining.text = "\(minutes)"+":"+"0"+"\(seconds)"}
        else {self.timeRemaining.text = "\(minutes)"+":"+"\(seconds)"}
    }

    @objc func scheduelTimer() {
        if (self.viewIfLoaded?.window) == nil || !AppDelegate.sharedPlayer.isPlaying { return }
        self.musicTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateSlider(animated: true)
            //self.updateTimeLabels()
        }
    }

    @objc func stopTimer(){
        self.musicTimer?.invalidate()
        self.musicTimer = nil
    }

    @objc func setup(){
        guard let _=AppDelegate.sharedPlayer.url else { return }
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.songURL = (delegate.currentPlaylist[delegate.arrayPos] as! Song).getURL()!
        
        guard let url = songURL else {return}
        artworkImage = getImage(songURL: url)
        songTitle.text = getTitle(songURL: url)
        songArtist.text = getArtist(songURL: url)
        backgroundArtwork.image = artworkImage
        mainArtwork.image = artworkImage
        
        //Time slider
        musicProgressSlider.value = 0
        timePassed.text = "0:00"
        self.timeRemaining.text = AppDelegate.sharedPlayer.duration.stringFromTimeInterval()
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
    
    @objc func updateRepeatStatusBTN(){
        switch (UIApplication.shared.delegate as! AppDelegate).isRepeating {
            case .noRepeat:
                reapeatBTN.tintColor = .white
                if #available(iOS 13.0, *) {
                    let largeConfig = UIImage.SymbolConfiguration(textStyle: .title2)
                    reapeatBTN.setImage(UIImage(systemName: "repeat", withConfiguration: largeConfig), for: .normal)
                }
            case .repeatPlaylist:
                reapeatBTN.tintColor = mainRed
                if #available(iOS 13.0, *) {
                    let largeConfig = UIImage.SymbolConfiguration(textStyle: .title2)
                    reapeatBTN.setImage(UIImage(systemName: "repeat", withConfiguration: largeConfig), for: .normal)
                }
            case .repeatSong:
                reapeatBTN.tintColor = mainRed
                if #available(iOS 13.0, *) {
                    let largeConfig = UIImage.SymbolConfiguration(textStyle: .title2)
                    reapeatBTN.setImage(UIImage(systemName: "repeat.1", withConfiguration: largeConfig), for: .normal)
                }
        }
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
        MusicController().skipForward()
    }
    
    @objc func shuffle(){
        MusicController().shuffle()
    }
    
    @objc func repeatAction(){
        MusicController().updateRepeatStatus()
    }
    
    @objc func changeSongTime(){
        MusicController().changeSongTime(time: TimeInterval(musicProgressSlider.value))
        // The next two lines should be removed when time labels are stable when integrated with the timer
        self.timeRemaining.text = (
            AppDelegate.sharedPlayer.duration - AppDelegate.sharedPlayer.currentTime).stringFromTimeInterval()
        self.timePassed.text = AppDelegate.sharedPlayer.currentTime.stringFromTimeInterval()
    }

    @objc func sliderTouchEvent(slider: UISlider, event: UIEvent){
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                self.stopTimer()
            case .ended:
                // Possible to place changeSongTime() in a .moved case.
                // To do this the play control would have to be removed
                // From the changeSongTime() and move to the .ended case
                // For best experience. For now this is uneeded.
                changeSongTime()
                scheduelTimer()
            default:
                break
            }
        }
    }

    @objc func sliderTouchEnded(){
        changeSongTime()
        scheduelTimer()
    }

    @objc func audioSessionInterrupted(){
        
    }

    @objc func volumeChanged(notification: NSNotification) {
        let volume = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as! Float
        volumeSlider.setValue(volume, animated: true)
    }
    
    @objc func changeVolume(){
        //Should move functionality to MusicController
        MPVolumeView.setVolume(volumeSlider.value)
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
        //timeRemaining.text = "0:00"
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
        musicProgressSlider.addTarget(self, action: #selector(sliderTouchEvent(slider:event:)), for: .allTouchEvents)
        
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
        volumeSlider.addTarget(self, action: #selector(changeVolume), for: .valueChanged)
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

extension MPVolumeView {
  static func setVolume(_ volume: Float) {
    let volumeView = MPVolumeView()
    let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
      slider?.value = volume
    }
  }
}
