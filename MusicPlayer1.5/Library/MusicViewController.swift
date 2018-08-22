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

class MusicViewController: UIViewController {

    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var flippedArtwork: UIImageView!
    @IBOutlet weak var topArtwork: UIImageView!
    
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var musicProgress: UISlider!
    @IBOutlet weak var timeElapsed: UILabel!
    @IBOutlet weak var timeLeft: UILabel!

    
    
    var url: URL = Bundle.main.url(forResource: "Day N Night", withExtension: ".mp3", subdirectory: "Music Library")!
    var timeAV: Float = 0.0
    var leftAV: Float = 0.0
    var min: Int = 0
    var sec: Int = 0
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "\(musicVC.arrayPos+1) of \(userData.downloadLibrary.count)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup(theURL: url)
        setupRemoteTransportControls()
        setupNowPlaying()
        (musicVC.nav.viewControllers[1] as? ViewController)?.nowPlaying.isHidden = false
        (musicVC.nav.viewControllers[1] as? ViewController)?.nowPlaying.isEnabled = true
        (musicVC.nav.viewControllers.first as? LibraryViewController)?.nowPlayingBTN.isHidden = false

        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            musicVC.player?.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play_arrow_white_54x54"), for: .normal)
            return .success
        }
        
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            musicVC.player?.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget{(event) in
            //
            return .success
        }
        
        
        let wrapperView = UIView(frame: CGRect(x: 35, y: 629, width: 304, height: 31))
        self.view.addSubview(wrapperView)
        _ = MPVolumeView(frame: wrapperView.bounds)
        
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        }
        catch{}

       _ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(MusicViewController.updateSlider), userInfo: nil, repeats: true)
        
        musicProgress.maximumValue = Float((musicVC.player?.duration)!)
    }
    
    deinit {
        print("denit called")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func playPause(_ sender: Any) {
        if !(musicVC.player?.isPlaying)! {
            musicVC.player?.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
            (musicVC.nav.viewControllers.first as? LibraryViewController)?.playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_pause_circle_filled_black_48pt"), for: .normal)
            (musicVC.nav.viewControllers[1] as? ViewController)?.playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_pause_circle_filled_black_48pt"), for: .normal)
        }
            
        else {
            musicVC.player?.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play_arrow_white_54x54"), for: .normal)
            (musicVC.nav.viewControllers.first as? LibraryViewController)?.playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_play_circle_filled_white_black_48pt"), for: .normal)
            (musicVC.nav.viewControllers[1] as? ViewController)?.playPauseBTN.setImage(#imageLiteral(resourceName: "baseline_play_circle_filled_white_black_48pt"), for: .normal)
        }
    }
    
    @IBAction func restart(_ sender: Any) {
        musicVC.player?.stop()
        musicVC.player?.currentTime=0
        musicVC.player?.play()
    }
    
    @IBAction func changeAudioTime(_ sender: Any) {
        if (musicVC.player?.isPlaying)! {
            musicVC.player?.stop()
            musicVC.player?.currentTime = TimeInterval(musicProgress.value)
            musicVC.player?.prepareToPlay()
            musicVC.player?.play()
        }
        else {
            musicVC.player?.stop()
            musicVC.player?.currentTime = TimeInterval(musicProgress.value)
            musicVC.player?.prepareToPlay()
        }
    }
    
    @IBAction func nextSong(_ sender: Any) {
        musicVC.player?.stop()
        
        switch musicVC.isShuffled {
        case true:
            if musicVC.arrayPos+1 == userData.shuffledLibrary.count {
                musicVC.arrayPos = 0
            }
            else {
                musicVC.arrayPos += 1
            }
            
            url = userData.shuffledLibrary[musicVC.arrayPos]
            setup(theURL: userData.shuffledLibrary[musicVC.arrayPos])
            //tableVC.library.populateNowPlayBar(url: userData.shuffledLibrary[musicVC.arrayPos])
            (musicVC.nav.viewControllers[1] as! ViewController).populateNowPlayBar(url: userData.shuffledLibrary[musicVC.arrayPos])
            (musicVC.nav.viewControllers.first as! LibraryViewController).populateNowPlyingBar(url: userData.shuffledLibrary[musicVC.arrayPos])
            
            do{musicVC.player = try AVAudioPlayer(contentsOf: userData.shuffledLibrary[musicVC.arrayPos])}
            catch{print("Song does not exist.")}
        case false:
            if musicVC.arrayPos+1 == userData.downloadLibrary.count {
                musicVC.arrayPos = 0
            }
            else {
                musicVC.arrayPos += 1
            }
            
            url = userData.downloadLibrary[musicVC.arrayPos]
            setup(theURL: userData.downloadLibrary[musicVC.arrayPos])
            //tableVC.library.populateNowPlayBar(url: userData.downloadLibrary[musicVC.arrayPos])
            (musicVC.nav.viewControllers[1] as! ViewController).populateNowPlayBar(url: userData.downloadLibrary[musicVC.arrayPos])
            (musicVC.nav.viewControllers.first as! LibraryViewController).populateNowPlyingBar(url: userData.downloadLibrary[musicVC.arrayPos])
            
            do{musicVC.player = try AVAudioPlayer(contentsOf: userData.downloadLibrary[musicVC.arrayPos])}
            catch{print("Song does not exist.")}
        default:
            break
        }

        musicProgress.maximumValue = Float((musicVC.player?.duration)!)
        musicVC.player?.prepareToPlay()
        playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
        musicVC.player?.play()
    }
    
    func next() {
        musicVC.player?.stop()
        
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
        topArtwork.image = getImage(songURL: theURL)
        songName.text = getTitle(songURL: theURL)
        artistName.text = getArtist(songURL: theURL)
        self.title = "\(musicVC.arrayPos+1) of \(userData.downloadLibrary.count)"
    }

    
    
    func getArtist(songURL: URL) -> String {
        var theArtist: String = "Unknown Artist"
        
        let item = AVPlayerItem(url: songURL)
        let metadata = item.asset.metadata
        
        for theItem in metadata {
            if theItem.commonKey == nil { continue }
            if let key = theItem.commonKey, let value = theItem.value {
                if key == "artist"
                {theArtist = value as! String}
            }
        }
        return theArtist
    }
    
    func getTitle(songURL: URL) -> String {
        var theTitle: String = "No Title"
        
        let item = AVPlayerItem(url: songURL)
        let metadata = item.asset.metadata
        
        for theItem in metadata {
            if theItem.commonKey == nil { continue }
            if let key = theItem.commonKey, let value = theItem.value {
                if key == "title"
                {theTitle = value as! String}
            }
        }
        return theTitle
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
    
    func flipImageDown(theImage: UIImage) -> UIImage {
        return UIImage(cgImage: theImage.cgImage!, scale: theImage.scale, orientation: UIImageOrientation.downMirrored)
        }
    
    
    
    func updateSlider() {
        musicProgress.setValue(Float((musicVC.player?.currentTime)!), animated: true)
        
        timeAV = round(Float((musicVC.player?.currentTime)!))
        leftAV = round(Float((musicVC.player?.duration)!)-Float((musicVC.player?.currentTime)!))
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
        {timeLeft.text = "\(min)"+":"+"\(sec)"}
        if Int((musicVC.player?.currentTime)!) == Int((musicVC.player?.duration)!)
        {nextButton.sendActions(for: .touchUpInside)
            //tableVC.library.Console.text = "NEXT"
        }
    }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if musicVC.player?.rate == 0.0 {
                musicVC.player?.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if musicVC.player?.rate == 1.0 {
                musicVC.player?.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    func setupNowPlaying() {
        // Define Now Playing Info
        let item = AVPlayerItem(url: url)
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = getTitle(songURL: url)
        nowPlayingInfo[MPMediaItemPropertyArtist] = getArtist(songURL: url)
        //nowPlayingInfo[MPMediaItemPropertyArtwork] = getImage(songURL: url)
        
        if let image = UIImage(named: "lockscreen") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: getImage(songURL: url).size) { size in
                    return self.getImage(songURL: self.url)
            }
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = item.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = item.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = musicVC.player?.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
}


