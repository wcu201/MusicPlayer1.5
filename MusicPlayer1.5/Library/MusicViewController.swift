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
        //appDelegate = UIApplication.shared.delegate as! AppDelegate
    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.player.delegate = self
        setup(theURL: url)
        setupRemoteTransportControls()
        setupNowPlaying()
        //let thumb = UIImage(named: "Image")!
        //var x = #imageLiteral(resourceName: "baseline_volume_mute_black_48dp")
        //x.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: <#T##CGFloat#>, bottom: <#T##CGFloat#>, right: <#T##CGFloat#>))
        //musicProgress.thumbTintColor = UIColor(red: 206.0/255.0, green: 24.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        musicProgress.setThumbImage(resizeImage(image: UIImage(named: "custom_thumb")!, targetSize: CGSize(width: 20, height: 20)), for: .normal)
        volumeSlider.tintColor = UIColor(red: 206.0/255.0, green: 24.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        //volumeSlider.setMinimumTrackImage(#imageLiteral(resourceName: "baseline_volume_mute_black_48dp"), for: .normal)
        //volumeSlider.setMaximumTrackImage(#imageLiteral(resourceName: "baseline_volume_up_black_48dp"), for: .normal)
        //volumeSlider.setMinimumTrackImage(resizeImage(image: #imageLiteral(resourceName: "baseline_volume_mute_black_48dp"), targetSize: CGSize(width: 20, height: 20)), for: .normal)
        //volumeSlider.setMaximumTrackImage(resizeImage(image: #imageLiteral(resourceName: "baseline_volume_up_black_48dp"), targetSize: CGSize(width: 20, height: 20)), for: .normal)
        //musicProgress.thumbImage(for: .normal).transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.appDelegate.player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play_arrow_white_54x54"), for: .normal)
            return .success
        }
        
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.appDelegate.player.play()
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
        
        print(appDelegate.player.duration)
        musicProgress.maximumValue = Float((appDelegate.player.duration))
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        nextButton.sendActions(for: .touchUpInside)
    }
    
    deinit {
        print("denit called")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playPause(_ sender: Any) {
        if !(appDelegate.player.isPlaying) {
            appDelegate.player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
        }
            
        else {
            appDelegate.player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play_arrow_white_54x54"), for: .normal)
        }
    }
    
    @IBAction func restart(_ sender: Any) {
        if appDelegate.player.currentTime > 1 {
            appDelegate.player.stop()
            appDelegate.player.currentTime=0
            playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
            appDelegate.player.play()
        }
        else {
            appDelegate.player.stop()
            if appDelegate.arrayPos == 0 {appDelegate.arrayPos = appDelegate.selectedLibrary.count-1}
            else {appDelegate.arrayPos-=1}
            
            appDelegate.songPlaying = appDelegate.selectedLibrary[appDelegate.arrayPos]
            setup(theURL: appDelegate.songPlaying!)
            setupNowPlaying()
            
            do{appDelegate.player = try AVAudioPlayer(contentsOf: appDelegate.songPlaying!)}
            catch{print("Song doesn't exist")}
            
            playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
            appDelegate.player.play()
        }
    }
    
    @IBAction func changeAudioTime(_ sender: Any) {
        if (appDelegate.player.isPlaying) {
            appDelegate.player.stop()
            appDelegate.player.currentTime = TimeInterval(musicProgress.value)
            appDelegate.player.prepareToPlay()
            appDelegate.player.play()
        }
        else {
            appDelegate.player.stop()
            appDelegate.player.currentTime = TimeInterval(musicProgress.value)
            appDelegate.player.prepareToPlay()
        }
    }
    
    @IBAction func nextSong(_ sender: Any) {
        appDelegate.player.stop()
        
        //WARNING: Underneath is a lot of deprecated code that needs fixing. May be the source of future problems
        /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        //update the array position to that of the next song
        if appDelegate.arrayPos+1 == appDelegate.selectedLibrary.count{appDelegate.arrayPos = 0}
        else {appDelegate.arrayPos += 1}
        
        if appDelegate.isShuffled {url = appDelegate.shuffledLibrary[appDelegate.arrayPos]}
        else{url = appDelegate.selectedLibrary[appDelegate.arrayPos]}
 
        setup(theURL: url)
        setupNowPlaying()
        
        //load the url onto the avplayer
        do{appDelegate.player = try AVAudioPlayer(contentsOf: url)}
        catch{print("Song doesn't exist")}

        //Start the play song process 
        musicProgress.maximumValue = Float((appDelegate.player.duration))
        appDelegate.player.prepareToPlay()
        playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
        appDelegate.player.play()
        appDelegate.songPlaying = url
    }
    
    func next() {
        self.appDelegate.player.stop()
        
        if musicVC.arrayPos+1 == userData.songLibrary.count {
            musicVC.arrayPos = 0
        }
        else {
            musicVC.arrayPos += 1
        }
        
        setup(theURL: userData.songLibrary[musicVC.arrayPos])
        
        
        do{
            musicVC.player = try AVAudioPlayer(contentsOf: userData.songLibrary[musicVC.arrayPos])}
        catch{print("Song does not exist.")}
        
        musicProgress.maximumValue = Float((musicVC.player?.duration)!)
        musicVC.player?.prepareToPlay()
        musicVC.player?.play()
    }
    
    func setup(theURL: URL){
        artwork.image = getImage(songURL: theURL)
        flippedArtwork.image = flipImageDown(theImage: getImage(songURL: theURL))
        topArtwork.image = blurImage(usingImage: getImage(songURL: theURL), blurAmount: 60.0)
        songName.text = getTitle(songURL: theURL)
        artistName.text = getArtist(songURL: theURL)
        self.title = "\(appDelegate.arrayPos+1) of \(appDelegate.selectedLibrary.count)"
        self.playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
    }
    
    @objc func updateSlider() {
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
        if Int(appDelegate.player.currentTime) == Int(appDelegate.player.duration)
        {nextButton.sendActions(for: .touchUpInside)}
    }
    
    
    @IBAction func changeVolume(_ sender: Any) {
        appDelegate.player.volume = volumeSlider.value
    }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.appDelegate.player.rate == 0.0 {
                self.appDelegate.player.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.appDelegate.player.rate == 1.0 {
                self.appDelegate.player.pause()
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
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.appDelegate.player.rate
        
        // Set the Metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
}


