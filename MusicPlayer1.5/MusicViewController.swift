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
    
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var artistName: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var musicProgress: UISlider!
    
    @IBOutlet weak var timeElapsed: UILabel!
    
    @IBOutlet weak var timeLeft: UILabel!
    
    @IBOutlet weak var console: UILabel!
    
    
    var url: URL = Bundle.main.url(forResource: "Gone", withExtension: ".mp3", subdirectory: "Music Library")!
    var timeAV: Float = 0.0
    var leftAV: Float = 0.0
    var min: Int = 0
    var sec: Int = 0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       setup(theURL: url)
        
        tableVC.library.showNowPlaying()

        
        var wrapperView = UIView(frame: CGRect(x: 35, y: 629, width: 304, height: 31))
        
        self.view.addSubview(wrapperView)
        
        // 3
        var volumeView = MPVolumeView(frame: wrapperView.bounds)
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do{
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        }
        catch{}

    
       _ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(MusicViewController.updateSlider), userInfo: nil, repeats: true)
        
        musicProgress.maximumValue = Float((musicVC.player?.duration)!)
        
        //self.navigationController?.navigationBar.backItem?.backBarButtonItem?.action =

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func playPause(_ sender: Any) {
        if !(musicVC.player?.isPlaying)!
        {
            musicVC.player?.play()
            
            playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
        }
            
        else
        {
            musicVC.player?.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play_arrow_white_54x54"), for: .normal)
        }
    }
    
    @IBAction func restart(_ sender: Any) {
        musicVC.player?.stop()
        musicVC.player?.currentTime=0
        musicVC.player?.play()
        playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
    }
    
    @IBAction func changeAudioTime(_ sender: Any) {
        if (musicVC.player?.isPlaying)!
        {
            musicVC.player?.stop()
            musicVC.player?.currentTime = TimeInterval(musicProgress.value)
            musicVC.player?.prepareToPlay()
            musicVC.player?.play()
        }
        else
        {
            musicVC.player?.stop()
            musicVC.player?.currentTime = TimeInterval(musicProgress.value)
            musicVC.player?.prepareToPlay()
        }
    }
    
    @IBAction func nextSong(_ sender: Any) {
        musicVC.player?.stop()
       
        if musicVC.arrayPos+1 == userData.songLibrary.count
        {
            musicVC.arrayPos = 0
        }
        else{
            musicVC.arrayPos += 1
        }
        
        setup(theURL: userData.songLibrary[musicVC.arrayPos])
        
        tableVC.library.populateNowPlayBar(url: userData.songLibrary[musicVC.arrayPos])
        
        do{
            musicVC.player = try AVAudioPlayer(contentsOf: userData.songLibrary[musicVC.arrayPos])}
        catch{print("Song does not exist.")}

        musicProgress.maximumValue = Float((musicVC.player?.duration)!)
        musicVC.player?.prepareToPlay()
        musicVC.player?.play()
    }
    
    func next()
    {
        musicVC.player?.stop()
        
        if musicVC.arrayPos+1 == userData.songLibrary.count
        {
            musicVC.arrayPos = 0
        }
        else{
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
        songName.text = getTitle(songURL: theURL)
        artistName.text = getArtist(songURL: theURL)
    }

    
    
    func getArtist(songURL: URL) -> String
    {
        var theArtist: String = ""
        
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
    
    func getTitle(songURL: URL) -> String
    {
        var theTitle: String = ""
        
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
    
    func getImage(songURL: URL) -> UIImage
    {
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
    
    func flipImageDown(theImage: UIImage) -> UIImage
    {
        
        return UIImage(cgImage: theImage.cgImage!, scale: theImage.scale, orientation: UIImageOrientation.downMirrored)
        
        
    }
    
    
    
    func updateSlider()
    {
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
}


