//
//  Song.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 5/10/20.
//  Copyright © 2020 William  Uchegbu. All rights reserved.
//

import UIKit
import CoreData

class Song: NSManagedObject {
    override func prepareForDeletion() {
        // Handle Deletion behavior
        
        // Delete Artist if this is his last song left
        if self.songArtist?.songs?.count == 1 {
            self.managedObjectContext?.delete(songArtist!)
        }
        
        // Delete Album if this is it's last song left
        if self.songAlbum?.songs?.count == 1 {
            self.managedObjectContext?.delete(songAlbum!)
        }
    }
}
