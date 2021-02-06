//
//  Song.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 5/10/20.
//  Copyright © 2020 William  Uchegbu. All rights reserved.
//

import UIKit
import CoreData

public class Song: NSManagedObject {
    public override func prepareForDeletion() {
        // Handle Deletion behavior
        
        if let url = self.getURL() {
            AppDelegate.deleteFromLibrary(url: url)
        }
        
        // Delete Artist if this is his last song left
        if let artist = self.songArtist, let songs = artist.songs, songs.count == 1 {
            self.managedObjectContext?.delete(artist)
        }

        // Delete Album if this is it's last song left
        if let album = self.songAlbum, let songs = album.songs, songs.count == 1 {
            self.managedObjectContext?.delete(album)
        }
    }
    
    public func getURL() -> URL? {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            return fileURLs.first(where: {$0.lastPathComponent == self.urlPath}) ?? nil
        }
        catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        return nil
    }
    
    public func addURL(url: URL) {
        guard let context = self.managedObjectContext else {
            print("Cannot add URL. Song has not context")
            return
        }
        self.artwork = getImage(songURL: url).pngData()
        self.title = getTitle(songURL: url)
        self.urlPath = url.lastPathComponent
        self.timeStamp = Date()
        
        var artist: Artist?
        var album: Album?

        let aritstName = getArtist(songURL: url)
        if let artist = CoreDataUtils.fetchEntity(entity: Artist.self, key: "title", value: aritstName, context: context){
            self.songArtist = artist
        }
        else {
            artist = Artist(context: context)
            artist?.title = getArtist(songURL: url)
            self.songArtist = artist
        }
        
        let albumName = getAlbum(songURL: url)
        if let album = CoreDataUtils.fetchEntity(entity: Album.self, key: "title", value: albumName, context: context){
            self.songAlbum = album
        }
        else {
            album = Album(context: context)
            album?.title = albumName
            album?.albumArtist = artist
            self.songAlbum = album
        }
            
        do {
            try context.save()
        }
        catch {
            // CoreData Error
            print(error)
        }
    }
    
    public func updateDownloadProgress(fractionCompleted: Double){
        guard let context = self.managedObjectContext else { return }
        let downloadProgress = 100 * fractionCompleted
        self.downloadProgress = downloadProgress
        do {
            try context.save()
            let notificationCenter = NotificationCenter.default
            let userInfo = [
                "progress" : downloadProgress,
                "songID" : self.songID?.uuidString
            ] as [String : Any]
            notificationCenter.post(name: .downloadProgressUpdated, object: self, userInfo: userInfo)
        }
        catch {}
    }
}
