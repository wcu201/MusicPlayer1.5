//
//  AppDelegate.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 9/3/17.
//  Copyright © 2017 William  Uchegbu. All rights reserved.
//

import UIKit
import AVKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var downloadLibrary = [URL]()
    var shuffledLibrary = [URL]()
    var selectedLibrary = [URL]()
    
    var currentPlaylist = [URL]()
    var artistsLibraries = [String : [URL]]()
    var albumLibraries = [String : [URL]]()
    var playlistsLibraries = [String : URL]()
    var recentlyAddedQueue  = [URL]()
    
    var isShuffled = false
    var musicPlaying = false
    var player = AVAudioPlayer()
    var playerVC: MusicViewController?
    var songPlaying: URL?
    var arrayPos = Int()
    
    var downloadProgressQueue = [URL:Float]() 

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIDeviceOrientation.portrait
        populateDownloadLibrary()
        populateArtistLibraries()
        populateAlbumLibraries()
        /*
        let mp3FileReader = Mp3FileReader()
        do {
            let mp3Data = try mp3FileReader.readFrom(path: downloadLibrary[0])
            //print("testing")
        }
        catch {
            print("error")
        }*/
        
        /*player.addObserver(<#T##observer: NSObject##NSObject#>, forKeyPath: <#T##String#>, options: <#T##NSKeyValueObservingOptions#>, context: <#T##UnsafeMutableRawPointer?#>)*/
        //print("Player Status: ")
        //playerVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MusicViewController") 
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func populateDownloadLibrary(){
        //Gathers all downloaded files and returns their urls
            var downloads = [URL]()
            
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                for song in fileURLs {
                    downloads.append(song)
                }
            }
            catch {
                print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
            }
        downloadLibrary = downloads
    }
    
    func populateArtistLibraries(){
        var library = [String : [URL]]()
        
        for url in downloadLibrary{
            let artist = getArtist(songURL: url)
            if library.keys.contains(artist) {library[artist]?.append(url)}
            else {library[artist] = [url]}
        }
        
        artistsLibraries = library
    }
    
    func populateAlbumLibraries(){
        var library = [String : [URL]]()
        
        for url in downloadLibrary{
            let album = getAlbum(songURL: url)
            if library.keys.contains(album) {library[album]?.append(url)}
            else {library[album] = [url]}
        }
        
        albumLibraries = library
    }
    
    func deleteFromLibrary(url: URL){
        do {
            //stop everything before removing item from library
            print("Deleting from library")
            /*if(player.data != nil){
                player.stop()
            }*/
            player = AVAudioPlayer()
            
            try FileManager.default.removeItem(at: url)
        }
        catch {
            print("Error: Cannot find ", url)
        }
        
        populateDownloadLibrary()
    }

}

