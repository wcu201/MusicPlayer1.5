//
//  Album.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 5/10/20.
//  Copyright © 2020 William  Uchegbu. All rights reserved.
//

import UIKit
import CoreData

class Album: NSManagedObject {

}

func fetchAlbum(title: String, context: NSManagedObjectContext)->Album? {
    let fetchRequest = NSFetchRequest<Album>(entityName: "Album")
    let predicate = NSPredicate(format: "title = %d", title)
    fetchRequest.predicate = predicate
    
    var results: [Album]?
    do {
        results = try context.fetch(fetchRequest)
    }
    catch {
        print("error executing fetch request: \(error)")
    }
    
    if let albums = results {
        //TODO: Handle duplicates in BrowserViewController
        return albums.first
    }
    
    return nil
}
