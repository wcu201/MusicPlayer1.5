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
}
