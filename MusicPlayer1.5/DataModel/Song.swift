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
        
//        // Delete Artist if this is his last song left
//        if self.songArtist?.songs?.count == 1 {
//            self.managedObjectContext?.delete(songArtist!)
//        }
//
//        // Delete Album if this is it's last song left
//        if self.songAlbum?.songs?.count == 1 {
//            self.managedObjectContext?.delete(songAlbum!)
//        }
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
