//
//  AlbumLibrary.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 6/12/20.
//  Copyright © 2020 William  Uchegbu. All rights reserved.
//

import Foundation
import CoreData

public class Library: NSObject {
    private let mainContext: NSManagedObjectContext?
    
    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
        super.init()
    }
    
    func resultsController(entityName: String) -> NSFetchedResultsController<Album> {
        let fetchRequest = NSFetchRequest<Album>(entityName: "Album")
        let sortByName = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        fetchRequest.sortDescriptors = [sortByName]
        fetchRequest.predicate = nil
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.mainContext!, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }
}
