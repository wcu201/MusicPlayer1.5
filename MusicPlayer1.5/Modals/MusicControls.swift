//
//  MusicControls.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 4/9/20.
//  Copyright © 2020 William  Uchegbu. All rights reserved.
//

import Foundation
import AVKit
import UIKit

class MusicController {
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    public func pauseSong() {
        AppDelegate.sharedPlayer.pause()
        NotificationCenter.default.post(
            name: .songPaused,
            object: self,
            userInfo: nil)
    }
    
    public func playSong() {
        AppDelegate.sharedPlayer.play()
        NotificationCenter.default.post(
            name: .songPlayed,
            object: self,
            userInfo: nil)
    }
    public func skipBack() {
        if AppDelegate.sharedPlayer.currentTime < 2 {
            previousSong()
        }
        else {
            restartSong()
        }
    }
    
    public func restartSong() {
        AppDelegate.sharedPlayer.stop()
        AppDelegate.sharedPlayer.currentTime = 0
        AppDelegate.sharedPlayer.prepareToPlay()
        AppDelegate.sharedPlayer.play()
        NotificationCenter.default.post(
            name: .songPlayed,
            object: self,
            userInfo: nil)
    }
    
    public func stopSong() {
        AppDelegate.sharedPlayer.stop()
        AppDelegate.sharedPlayer.currentTime = 0
        NotificationCenter.default.post(
            name: .songPaused,
            object: self,
            userInfo: nil)
    }
    
    public func previousSong() {
        AppDelegate.sharedPlayer.stop()
        var index = appDelegate.arrayPos
        if appDelegate.arrayPos == 0 {index = appDelegate.selectedLibrary.count-1}
        else {index-=1}
        
        appDelegate.arrayPos = index
        let url = appDelegate.selectedLibrary[index]
        
        //Need to add observers/listeners
        //setup(theURL: url)
        //setupNowPlaying()
        
        //load the url onto the avplayer
        do{AppDelegate.sharedPlayer = try AVAudioPlayer(contentsOf: url)}
        catch{print("Song doesn't exist")}
        
        //Start the play song process
        //musicProgress.maximumValue = Float((audioPlayer.duration))
        AppDelegate.sharedPlayer.prepareToPlay()
        //playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
        AppDelegate.sharedPlayer.play()
        NotificationCenter.default.post(
            name: .songPlayed,
            object: self,
            userInfo: nil)
        appDelegate.songPlaying = url
    }
    
    public func nextSong() {
        AppDelegate.sharedPlayer.stop()
        var index = appDelegate.arrayPos
        if appDelegate.arrayPos == appDelegate.selectedLibrary.count-1 {
            index = 0
        }
        else {index+=1}
        
        appDelegate.arrayPos = index
        let url = appDelegate.selectedLibrary[index]
        
        //Need to add observers/listenersz
        //setup(theURL: url)
        //setupNowPlaying()
        
        //load the url onto the avplayer
        do{AppDelegate.sharedPlayer = try AVAudioPlayer(contentsOf: url)}
        catch{print("Song doesn't exist")}
        
        AppDelegate.sharedPlayer.delegate = appDelegate
        //Start the play song process
        //musicProgress.maximumValue = Float((audioPlayer.duration))
        AppDelegate.sharedPlayer.prepareToPlay()
        //playPauseButton.setImage(#imageLiteral(resourceName: "pause_white_54x54"), for: .normal)
        AppDelegate.sharedPlayer.play()
        NotificationCenter.default.post(
            name: .songPlayed,
            object: self,
            userInfo: nil)
        appDelegate.songPlaying = url
    }
    
    public func shuffle(){
        
    }
    
    public func changeSongTime(time: TimeInterval) {

    }
    
    public func playSongAtTime(time: TimeInterval) {

    }
}
