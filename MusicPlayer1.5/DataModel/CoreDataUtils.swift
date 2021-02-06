//
//  CoreDataUtils.swif.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 6/14/20.
//  Copyright © 2020 William  Uchegbu. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataUtils: NSObject {
    public static func fetchEntity<T:NSManagedObject>(entity:T.Type, key: String, value: String, context: NSManagedObjectContext)->T? {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entity))
        fetchRequest.predicate = NSPredicate(format: "%K = %@", key, value)
        
        let results = try? context.fetch(fetchRequest)
        if let entities = results {
            //TODO: Handle duplicates in BrowserViewController
            return entities.first
        }
        
        return nil
    }
    
    public static func entityIsEmpty<T:NSManagedObject>(entity:T.Type, key: String, value: String, context: NSManagedObjectContext)->Bool {
        
        if let obj = CoreDataUtils.fetchEntity(entity: entity, key: key, value: value, context: context) {
            
            switch entity {
                case is Album.Type:
                    return (obj as! Album).songs?.count == 0
                case is Artist.Type:
                    return (obj as! Artist).songs?.count == 0
                default:
                    return true
            }
        }
        return true
    }
        
    public static func deleteIfEmpty<T:NSManagedObject>(entity:T.Type, key: String, value: String, context: NSManagedObjectContext) {
        if CoreDataUtils.entityIsEmpty(entity: entity, key: key, value: value, context: context) {
            
            if let obj = CoreDataUtils.fetchEntity(entity: entity, key: key, value: value, context: context) {
                context.delete(obj)
                try? context.save()
            }
            
        }
    }
    
    public static func addSongToCoreData(context: NSManagedObjectContext) -> (Song?, Error?) {
        let song = Song(context: context)
        song.songID = UUID()
        song.downloadProgress = 0
        song.downloaded = false
    
        do {
            try context.save()
            return (song, nil)
        }
        catch {
            //CoreData Error
            print(error)
            return (nil, error)
        }
    }
    
    public static func fetchSongs(context: NSManagedObjectContext, onlyCompletedDownloads: Bool, predicate: NSPredicate? = nil) -> NSFetchedResultsController<Song>? {
        let fetchRequest = NSFetchRequest<Song>(entityName: "Song")
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var predicates = [NSPredicate]()
        if onlyCompletedDownloads { predicates.append(completedDownloadsPredicate) }
        if let addedPredicate = predicate { predicates.append(addedPredicate)}
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = compoundPredicate
        
        let resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil )
        
        do {
            try resultsController.performFetch()
        }
        catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        return resultsController
    }
    
    public static var completedDownloadsPredicate: NSPredicate {
        return NSPredicate(format: "downloaded == YES")
    }
    
    public static func albumSongsPredicate(album: Album) -> NSPredicate {
        return NSPredicate(format: "songAlbum == %@", album)
    }
    
    public static func artistSongsPredicate(artist: Artist) -> NSPredicate {
        return NSPredicate(format: "songArtist == %@", artist)
    }
    
    public static func playlistSongsPredicate(playlist: Playlist) -> NSPredicate {
        return NSPredicate(format: "SELF IN %@", playlist.songs ?? NSSet())
    }

    public static func recentlyAddedPredicate() -> NSPredicate {
        let thirtyDays = TimeInterval(exactly: 3600 * 24 * 30)
        let thirtyDaysAgo = NSDate().addingTimeInterval(-thirtyDays!)
        return NSPredicate(format: "timeStamp >= %@", thirtyDaysAgo)
    }
}
