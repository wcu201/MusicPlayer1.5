//
//  AppDelegate.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 9/3/17.
//  Copyright © 2017 William  Uchegbu. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreData
import CoreAudio

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AVAudioPlayerDelegate {

    var window: UIWindow?
    
    static var downloadLibrary = [URL]()
    var shuffledLibrary = [URL]()

    
    var currentPlaylist = NSMutableOrderedSet(array: [URL]())
    var currentUnshuffledPlaylist: NSMutableOrderedSet?

    
    static var persistentContainer: NSPersistentContainer {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    static var viewContext: NSManagedObjectContext {
        return AppDelegate.persistentContainer.viewContext
    }
    
    var isShuffled: Bool = false {
        didSet {
            if isShuffled {
                NotificationCenter.default.post(name: .shuffleOn, object: self, userInfo: nil)
            }
            else {
                NotificationCenter.default.post(name: .shuffleOff, object: self, userInfo: nil)
            }
        }
    }
    
    var isRepeating: repeatStatus = .noRepeat {
        didSet {
            NotificationCenter.default.post(name: .repeatStatusChanged, object: self, userInfo: nil)
        }
    }
    
    var musicPlaying = false
    
    public static var sharedPlayer = AVAudioPlayer() {
        didSet {
            NotificationCenter.default.post(name: .songChanged, object: self, userInfo: nil)
            MusicController().setupNowPlaying()
        }
    }
    
    var songsVC: ViewController?
    var playerVC: MusicPlayerViewController?
    var songPlaying: URL?
    var arrayPos = Int() {
        didSet {
            NotificationCenter.default.post(name: .arrayPosChanged, object: self, userInfo: nil) 
        }
    }
    
    var downloadProgressQueue = [URL:Float]() 

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //Create all Entities
        //addAllSongsToCoreData()
        //removeAllSongs()
        //removeAllEntities()
        //removeAlbums()
        
//        let url1 = downloadLibrary[3]
//        let url2 = downloadLibrary[4]
//        deleteFromLibrary(url: url2)
        // Query Database example
//        let context = AppDelegate.viewContext
//        let request: NSFetchRequest<Song> = Song.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(
//            key: "title",
//            ascending: true,
//            selector: #selector(NSString.localizedCompare(_:)))
//        request.sortDescriptors = [sortDescriptor]
//        //let predicate = NSPredicate(format: "", <#T##args: CVarArg...##CVarArg#>)
//        request.predicate = nil
//        let songs = try? context.fetch(request)
//        if let theSongs = songs {
//            for song in theSongs {
//                let x = song.songID
//                print(x)
//            }
//            //try? context.save()
//        }
        return true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath=="isPlaying" {
            print(0)
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()

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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if isRepeating != .repeatSong {
            MusicController.nextSong()
        }
        
        if arrayPos != 0 || (isRepeating != .noRepeat) {
            AppDelegate.sharedPlayer.prepareToPlay()
            AppDelegate.sharedPlayer.play()
            NotificationCenter.default.post(
                name: .songPlayed,
                object: self,
                userInfo: nil)
        }
    }
    
    
    public static func populateDownloadLibrary(){
        // Gathers all downloaded files and returns their urls
            var downloads = [URL]()
            
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                for song in fileURLs {
//                    if song.pathExtension.isEmpty {
//                        var url2 = URL(string: song.absoluteString)
//                        url2?.appendPathExtension("mp3")
//
//                        let fileManager = FileManager.default
//                        if fileManager.fileExists(atPath: song.path) {
//                            do {
//                                try fileManager.replaceItemAt(song, withItemAt: url2!)
//                            }
//                            catch {
//
//                            }
//                        }
//                        downloads.append(url2!)
//                        continue
//                    }
                    downloads.append(song)
                }
            }
            catch {
                print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
            }
         downloadLibrary = downloads
    }
    
    //One time helper function for giving all mp3 files in documents a core data representation
    func addAllSongsToCoreData(){
        let context = AppDelegate.viewContext
        for url in AppDelegate.downloadLibrary {
            
            let song = Song(context: context)
            song.artwork = getImage(songURL: url).pngData()
            song.title = getTitle(songURL: url)
            song.urlPath = url.absoluteString

            let artist = Artist(context: song.managedObjectContext!)
            artist.title = getArtist(songURL: url)

            let album = Album(context: song.managedObjectContext!)
            album.title = getAlbum(songURL: url)
            
            album.albumArtist = artist
            song.songArtist = artist
            song.songAlbum = album
        }
        
        do {
            try context.save()
        }
        catch {
            //CoreData Error
        }
        
    }
    
    //One time function for deleting all songs from Core Data
    func removeAllSongs(){
        let context = AppDelegate.viewContext
                let request: NSFetchRequest<Song> = Song.fetchRequest()
                let sortDescriptor = NSSortDescriptor(
                    key: "title",
                    ascending: true,
                    selector: #selector(NSString.localizedCompare(_:)))
                request.sortDescriptors = [sortDescriptor]
                //let predicate = NSPredicate(format: "", <#T##args: CVarArg...##CVarArg#>)
                request.predicate = nil
                let songs = try? context.fetch(request)
                for song in songs! {
                    song.managedObjectContext?.delete(song)
                }
                do {
                    try context.save()
                }
                catch {
                    //CoreData Error
                }
    }
    
    func removeAlbums(){
        let context = AppDelegate.viewContext
                let request: NSFetchRequest<Album> = Album.fetchRequest()
                let sortDescriptor = NSSortDescriptor(
                    key: "name",
                    ascending: true,
                    selector: #selector(NSString.localizedCompare(_:)))
                request.sortDescriptors = [sortDescriptor]
                //let predicate = NSPredicate(format: "", <#T##args: CVarArg...##CVarArg#>)
                request.predicate = nil
                let songs = try? context.fetch(request)
                for song in songs! {
                    song.managedObjectContext?.delete(song)
                }
                do {
                    try context.save()
                }
                catch {
                    //CoreData Error
                    print(0)
                }
    }
    
    
    func removeAllEntities(){
        let songFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")
        let songDeleteRequest = NSBatchDeleteRequest(fetchRequest: songFetch)
        _ = try? AppDelegate.viewContext.execute(songDeleteRequest)
        
        let albumFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        let albumDeleteRequest = NSBatchDeleteRequest(fetchRequest: albumFetch)
        _ = try? AppDelegate.viewContext.execute(albumDeleteRequest)
        
        let artistFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Artist")
        let artistDelteRequest = NSBatchDeleteRequest(fetchRequest: artistFetch)
        _ = try? AppDelegate.viewContext.execute(artistDelteRequest)
        
        do {
            try AppDelegate.viewContext.save()
        }
        catch {
            //CoreData Error
        }
    }
    
    public static func deleteFromLibrary(url: URL){
        //This is probably broken
        do {
            //stop everything before removing item from library
            print("Deleting from library")
            AppDelegate.sharedPlayer = AVAudioPlayer()
            
            try FileManager.default.removeItem(at: url)
        }
        catch {
            print("Error: Cannot find ", url)
        }
        
        populateDownloadLibrary()
    }
    

}

