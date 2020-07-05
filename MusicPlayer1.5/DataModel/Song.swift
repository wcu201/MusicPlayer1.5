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
}
