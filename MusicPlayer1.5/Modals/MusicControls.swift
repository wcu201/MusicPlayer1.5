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
import MediaPlayer

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
            MusicController.previousSong()
        }
        else {
            restartSong()
        }
    }
    
    public func skipForward() {
        MusicController.nextSong()
        
        //Start the play song process
        AppDelegate.sharedPlayer.prepareToPlay()
        playSong()
//        AppDelegate.sharedPlayer.play()
//        NotificationCenter.default.post(
//            name: .songPlayed,
//            object: self,
//            userInfo: nil)
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
    
    public static func previousSong() {
        AppDelegate.sharedPlayer.stop()
        NotificationCenter.default.post(
            name: .songPaused,
            object: self,
            userInfo: nil)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var index = appDelegate.arrayPos
        if appDelegate.arrayPos == 0 {
            index = appDelegate.currentPlaylist.count-1
        }
        else {
            index-=1
        }
        
        appDelegate.arrayPos = index
        //let url = appDelegate.selectedLibrary[index]
        let url = (appDelegate.currentPlaylist[index] as! Song).getURL()!
        
        //load the url onto the avplayer
        do {
            AppDelegate.sharedPlayer = try AVAudioPlayer(contentsOf: url)
        }
        catch{
            // TODO: Handle URL error
        }
        
        AppDelegate.sharedPlayer.delegate = appDelegate
        MusicController().playSong()
//        //Start the play song process
//        AppDelegate.sharedPlayer.prepareToPlay()
//        AppDelegate.sharedPlayer.play()
//        NotificationCenter.default.post(
//            name: .songPlayed,
//            object: self,
//            userInfo: nil)
//        appDelegate.songPlaying = url
    }
    
    public static func nextSong() {
        AppDelegate.sharedPlayer.stop()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var index = appDelegate.arrayPos
        if appDelegate.arrayPos == appDelegate.currentPlaylist.count-1 /*appDelegate.selectedLibrary.count-1*/{
            index = 0
        }
        else {
            index += 1
        }
        
        appDelegate.arrayPos = index
        //let url = appDelegate.selectedLibrary[index]
        let url = (appDelegate.currentPlaylist[index] as! Song).getURL()!
        
        //load the url onto the avplayer
        do{
            AppDelegate.sharedPlayer = try AVAudioPlayer(contentsOf: url)
        }
        catch{
            // TODO: Handle URL error
        }
        
        AppDelegate.sharedPlayer.delegate = appDelegate
    }
    
    public func shuffle(){
        if appDelegate.isShuffled {
            let currentURL = AppDelegate.sharedPlayer.url
            let song = appDelegate.currentUnshuffledPlaylist!.first(where: {($0 as! Song).urlPath == currentURL?.lastPathComponent})
            let currentIndex = appDelegate.currentUnshuffledPlaylist?.index(of: song as Any)
            appDelegate.arrayPos = currentIndex!
            appDelegate.currentPlaylist = appDelegate.currentUnshuffledPlaylist!
            appDelegate.isShuffled = false
        }
        else {
            appDelegate.currentUnshuffledPlaylist = appDelegate.currentPlaylist
            var shuffledPlaylist = appDelegate.currentPlaylist.shuffled()
            appDelegate.currentPlaylist = NSMutableOrderedSet(array: shuffledPlaylist)
            
            let currentURL = AppDelegate.sharedPlayer.url
            let song = appDelegate.currentPlaylist.first(where: {($0 as! Song).urlPath == currentURL?.lastPathComponent})
            let currentIndex = appDelegate.currentPlaylist.index(of: song as Any)
            shuffledPlaylist.swapAt(0, currentIndex)
            appDelegate.currentPlaylist = NSMutableOrderedSet(array: shuffledPlaylist)
            
            appDelegate.arrayPos = 0
            appDelegate.isShuffled = true
        }
    }
    
    public func updateRepeatStatus() {
        if appDelegate.isRepeating == .repeatSong {
            appDelegate.isRepeating = .noRepeat
        }
        else {
            appDelegate.isRepeating = repeatStatus(
                rawValue: appDelegate.isRepeating.rawValue + 1) ?? .noRepeat
        }
    }
    
    // This function needs to take a ratio of currentTime/duration (always less than 1)
    public func changeSongTime(time: TimeInterval) {
        if (AppDelegate.sharedPlayer.isPlaying) {
            AppDelegate.sharedPlayer.stop()
            AppDelegate.sharedPlayer.currentTime = AppDelegate.sharedPlayer.duration * time
            AppDelegate.sharedPlayer.prepareToPlay()
            AppDelegate.sharedPlayer.play()
        }
        else {
            AppDelegate.sharedPlayer.currentTime = AppDelegate.sharedPlayer.duration * time
            AppDelegate.sharedPlayer.prepareToPlay()
        }
    }
    
    public func playSongAtTime(time: TimeInterval) {

    }
    
    public func attachToCommandCenter(){
        setupRemoteTransportControls()
        setupNowPlaying()
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let audioSession = AVAudioSession.sharedInstance()
        do{try audioSession.setCategory(AVAudioSession.Category.playback)}
        catch{}
    }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { event in
            self.playSong()
            return .success
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { event in
            self.pauseSong()
            return .success
        }
        
        // Add handler for Next Command
        commandCenter.nextTrackCommand.addTarget(handler: { event in
            self.skipForward()
            return .success
        })
        
        // Add handler for Restart Command
        commandCenter.previousTrackCommand.addTarget(handler: { event in
            self.skipBack()
            return .success
        })
        
        // Add handler for Change Playback Position Command
        commandCenter.changePlaybackPositionCommand.addTarget(handler: {event in
            let time = (event as! MPChangePlaybackPositionCommandEvent).positionTime
            self.changeSongTime(time: time/AppDelegate.sharedPlayer.duration)
            return .success
        })
        
        // Add handler for Change Shuffle Mode Command
        commandCenter.changeShuffleModeCommand.addTarget(handler: {event in
            // (event as! MPChangeShuffleModeCommandEvent).preservesShuffleMode
            self.shuffle()
            return .success
        })
        
        // Add handler for Repeat Mode Command
        commandCenter.changeRepeatModeCommand.addTarget(handler: {event in
            self.updateRepeatStatus()
            return .success
        })
    }
    
    func setupNowPlaying() {
        // Define Now Playing Info
        guard let _=AppDelegate.sharedPlayer.url else {
            return
        }
        
        guard let url = (appDelegate.currentPlaylist[appDelegate.arrayPos] as! Song).getURL() else {
            return
        }

        let item = AVPlayerItem(url: url)
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = getTitle(songURL: url)
        nowPlayingInfo[MPMediaItemPropertyArtist] = getArtist(songURL: url)
        nowPlayingInfo[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: getImage(songURL: url).size) { size in
                return getImage(songURL: url)
        }

        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = item.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = item.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = AppDelegate.sharedPlayer.rate
        
        // Set the Metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
