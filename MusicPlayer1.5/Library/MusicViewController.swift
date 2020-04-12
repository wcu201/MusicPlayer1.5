//
//  MusicViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 9/5/17.
//  Copyright © 2017 William  Uchegbu. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer

class MusicViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var flippedArtwork: UIImageView!
    @IBOutlet weak var topArtwork: UIImageView!
    
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var musicProgress: UISlider!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var timeElapsed: UILabel!
    @IBOutlet weak var timeLeft: UILabel!

    
    var appDelegate = AppDelegate()
    var url: URL = Bundle.main.url(forResource: "Day N Night", withExtension: ".mp3", subdirectory: "Music Library")!
    var timeAV: Float = 0.0
    var leftAV: Float = 0.0
    var min: Int = 0
    var sec: Int = 0
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "\(appDelegate.arrayPos+1) of \(appDelegate.selectedLibrary.count)"
        MainTabBarController.nowPlayingBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        MainTabBarController.nowPlayingBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        NotificationCenter.default.addObserver(self, selector: #selector(setup2), name: .songChanged, object: nil)
        
        setup(theURL: url)
        setupRemoteTransportControls()
        setupNowPlaying()
        appDelegate.songsVC?.showNowPlaying()
        //var x = #imageLiteral(resourceName: "baseline_volume_mute_black_48dp")
        //x.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: <#T##CGFloat#>, bottom: <#T##CGFloat#>, right: <#T##CGFloat#>))
        //musicProgress.thumbTintColor = UIColor(red: 206.0/255.0, green: 24.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        musicProgress.setThumbImage(resizeImage(image: UIImage(named: "custom_thumb")!, targetSize: CGSize(width: 20, height: 20)), for: .normal)
        volumeSlider.tintColor = UIColor(red: 206.0/255.0, green: 24.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        addBlur()
        //volumeSlider.setMinimumTrackImage(#imageLiteral(resourceName: "baseline_volume_mute_black_48dp"), for: .normal)
        //volumeSlider.setMaximumTrackImage(#imageLiteral(resourceName: "baseline_volume_up_black_48dp"), for: .normal)
        //volumeSlider.setMinimumTrackImage(resizeImage(image: #imageLiteral(resourceName: "baseline_volume_mute_black_48dp"), targetSize: CGSize(width: 20, height: 20)), for: .normal)
        //volumeSlider.setMaximumTrackImage(resizeImage(image: #imageLiteral(resourceName: "baseline_volume_up_black_48dp"), targetSize: CGSize(width: 20, height: 20)), for: .normal)
        //musicProgress.thumbImage(for: .normal).transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            //guard let audioPlayer = self.appDelegate.player else {return .commandFailed}

            AppDelegate.sharedPlayer.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play_arrow_white_54x54"), for: .normal)
            return .success
        }
        
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            //guard let audioPlayer = self.appDelegate.player else {return .commandFailed}

            AppDelegate.sharedPlayer.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget{(event) in
            /*
            if (self.appDelegate.player.isPlaying) {
                self.appDelegate.player.stop()
                self.appDelegate.player.currentTime = event.timestamp
                self.appDelegate.player.prepareToPlay()
                self.appDelegate.player.play()
            }
            else {
                self.appDelegate.player.stop()
                self.appDelegate.player.currentTime = event.timestamp
                self.appDelegate.player.prepareToPlay()
            }
             */
            return .success
        }
        
        
        let wrapperView = UIView(frame: CGRect(x: 35, y: 629, width: 304, height: 31))
        self.view.addSubview(wrapperView)
        _ = MPVolumeView(frame: wrapperView.bounds)
        
        let audioSession = AVAudioSession.sharedInstance()
        do{try audioSession.setCategory(AVAudioSession.Category.playback)}
        catch{}
        
        //VERY IMPORTANT - READ BELOW
        //This timer below might be very energy inefficent. Timer calls a specific task that consistantly runs in the background if the user is just idly listening to music. Need to test more to be sure, but I'm almost certain this is the cause of my battery issue. I've commented it out for now
        //After using some of the energy analytic tools it's pretty obvious that this timer is the cause of battery issues. The energy impact dips to 0 after I comment it out. Possible solution is to only have the scrubber active when the view is seen by the user
        //Added it again but commented out the graphics portion of the updateSlider function
        
       //_ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(MusicViewController.updateSlider), userInfo: nil, repeats: true)
        
        _ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(MusicViewController.updateSlider), userInfo: nil, repeats: true)
        
        musicProgress.maximumValue = Float((AppDelegate.sharedPlayer.duration))
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        nextButton.sendActions(for: .touchUpInside)
        print(0)
    }
    
    deinit {
        print("denit called")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playPause(_ sender: Any) {

        if !(AppDelegate.sharedPlayer.isPlaying) {
            AppDelegate.sharedPlayer.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
            MainTabBarController.playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_pause_circle_filled_black_48pt"), for: .normal)
        }
            
        else {
            AppDelegate.sharedPlayer.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play_arrow_white_54x54"), for: .normal)
            MainTabBarController.playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_play_circle_filled_white_black_48pt"), for: .normal)
        }
    }
    
    @IBAction func restart(_ sender: Any) {
        //guard let audioPlayer = appDelegate.player else {return}

        if AppDelegate.sharedPlayer.currentTime > 1 {
            AppDelegate.sharedPlayer.stop()
            AppDelegate.sharedPlayer.currentTime=0
            playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
            AppDelegate.sharedPlayer.play()
        }
        else {
            var index = appDelegate.arrayPos
            if appDelegate.arrayPos == 0 {index = appDelegate.selectedLibrary.count-1}
            else {index-=1}
            
            changeSong(index: index)
        }
    }
    
    @IBAction func changeAudioTime(_ sender: Any) {
        //guard let audioPlayer = appDelegate.player else {return}
        
        if (AppDelegate.sharedPlayer.isPlaying) {
            AppDelegate.sharedPlayer.stop()
            AppDelegate.sharedPlayer.currentTime = TimeInterval(musicProgress.value)
            AppDelegate.sharedPlayer.prepareToPlay()
            AppDelegate.sharedPlayer.play()
        }
        else {
            AppDelegate.sharedPlayer.stop()
            AppDelegate.sharedPlayer.currentTime = TimeInterval(musicProgress.value)
            AppDelegate.sharedPlayer.prepareToPlay()
        }
    }
    
    @IBAction func nextSong(_ sender: Any) {
        //WARNING: Underneath is a lot of deprecated code that needs fixing. May be the source of future problems
        /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        //update the array position to that of the next song
        var index = appDelegate.arrayPos
        if appDelegate.arrayPos+1 == appDelegate.selectedLibrary.count{index = 0}
        else {index += 1}
        
        if appDelegate.isShuffled {url = appDelegate.shuffledLibrary[appDelegate.arrayPos]}
        else{url = appDelegate.selectedLibrary[appDelegate.arrayPos]}
 
        changeSong(index: index)
    }
    
    func changeSong(index: Int) {
        //guard let audioPlayer = appDelegate.player else {return}
        AppDelegate.sharedPlayer.stop()
        appDelegate.arrayPos = index
        url = appDelegate.selectedLibrary[index]
        
        setup(theURL: url)
        setupNowPlaying()
        
        //load the url onto the avplayer
        do{AppDelegate.sharedPlayer = try AVAudioPlayer(contentsOf: url)}
        catch{print("Song doesn't exist")}
        
        //Start the play song process
        musicProgress.maximumValue = Float((AppDelegate.sharedPlayer.duration))
        AppDelegate.sharedPlayer.prepareToPlay()
        playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
        AppDelegate.sharedPlayer.play()
        appDelegate.songPlaying = url
    }
    
    func setup(theURL: URL){
        /*
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = flippedArtwork.frame
       // self.view.addSubview(blurEffectView)
        self.view.insertSubview(blurEffectView, aboveSubview: flippedArtwork)*/
        artwork.image = getImage(songURL: theURL)
        flippedArtwork.image = flipImageDown(theImage: getImage(songURL: theURL))
        //flippedArtwork.image = blurImage(usingImage: flippedArtwork.image!, blurAmount: 100.0)
        //topArtwork.image = blurImage(usingImage: getImage(songURL: theURL), blurAmount: 60.0)
        songName.text = getTitle(songURL: theURL)
        artistName.text = getArtist(songURL: theURL)
        self.title = "\(appDelegate.arrayPos+1) of \(appDelegate.selectedLibrary.count)"
        self.playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
    }
    
    func addBlur(){
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.insertSubview(blurEffectView, aboveSubview: flippedArtwork)
        
        self.view.addConstraints([
            NSLayoutConstraint(item: blurEffectView, attribute: .leading, relatedBy: .equal, toItem: flippedArtwork, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurEffectView, attribute: .trailing, relatedBy: .equal, toItem: flippedArtwork, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurEffectView, attribute: .top, relatedBy: .equal, toItem: flippedArtwork, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurEffectView, attribute: .bottom, relatedBy: .equal, toItem: flippedArtwork, attribute: .bottom, multiplier: 1, constant: 0)
            ])
    }
    
    @objc func setup2(){
        print(0)
    }
    
    @objc func updateSlider() {
        //guard let audioPlayer = appDelegate.player else {return}
        /*
        musicProgress.setValue(Float(appDelegate.player.currentTime), animated: true)
        timeAV = round(Float(appDelegate.player.currentTime))
        leftAV = round(Float(appDelegate.player.duration)-Float(appDelegate.player.currentTime))
        sec = Int(timeAV)%60
        min = Int(timeAV)/60
        if sec<10
        {timeElapsed.text = "\(min)"+":"+"0"+"\(sec)"}
        else
        {timeElapsed.text = "\(min)"+":"+"\(sec)"}
        sec = Int(leftAV)%60
        min = Int(leftAV)/60
        if sec<10
        {timeLeft.text = "\(min)"+":"+"0"+"\(sec)"}
        else
        {timeLeft.text = "\(min)"+":"+"\(sec)"}*/
        if Int(AppDelegate.sharedPlayer.currentTime) == Int(AppDelegate.sharedPlayer.duration)
        {nextButton.sendActions(for: .touchUpInside)}
    }
    
    
    @IBAction func changeVolume(_ sender: Any) {
        AppDelegate.sharedPlayer.volume = volumeSlider.value
    }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if AppDelegate.sharedPlayer.rate == 0.0 {
                AppDelegate.sharedPlayer.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if AppDelegate.sharedPlayer.rate == 1.0 {
                AppDelegate.sharedPlayer.pause()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Next Command
        commandCenter.nextTrackCommand.addTarget(handler: {[unowned self] event in
            self.nextButton.sendActions(for: .touchUpInside)
            return .success
        })
        
        // Add handler for Restart Command
        commandCenter.previousTrackCommand.addTarget(handler: {[unowned self] event in
            self.restart(self)
            return .success
        })
    }
    
    func setupNowPlaying() {
        // Define Now Playing Info
        let item = AVPlayerItem(url: url)
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = getTitle(songURL: url)
        nowPlayingInfo[MPMediaItemPropertyArtist] = getArtist(songURL: url)
        nowPlayingInfo[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: getImage(songURL: url).size) { size in
                return getImage(songURL: self.url)
        }

        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = item.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = item.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = AppDelegate.sharedPlayer.rate
        
        // Set the Metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
}


