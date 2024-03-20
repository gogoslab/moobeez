//
//  Database.swift
//  Moobeez
//
//  Created by Radu Banea on 01/11/2018.
//  Copyright © 2018 Gogo's Lab. All rights reserved.
//

import UIKit
import CoreData

class Database: NSObject {

    public var name:String = "Database"
    public var resourceName:String = "Database"
    
    public init(databaseName:String, resourceName:String? = nil) {
        super.init()
        name = databaseName
        self.resourceName = resourceName ?? name
        _ = persistentStoreCoordinator
        _ = context
    }
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
       
        let currentBundle = Bundle(for: type(of: self))
        let model = NSManagedObjectModel(contentsOf: currentBundle.url(forResource:resourceName, withExtension:"momd")!)
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: model!)
        
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.gogoslab.moobeez")
        
        let url = directory?.appendingPathComponent("\(name).sqlite")
        
        do {
            try coordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption: true])
        } catch var error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        Console.debug("\(String(describing: coordinator?.persistentStores))")
        return coordinator!
        
    }()
    
    public func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    lazy var context: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        var managedObjectContext = NSManagedObjectContext(concurrencyType:.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    public func fetch<T : NSManagedObject>(predicate:NSPredicate? = nil, sort sortDescriptors:[NSSortDescriptor]? = nil) -> [T] {
        
        let className = String(describing: T.self)
        
        let fetchRequest = NSFetchRequest<T> (entityName: className)
        
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            let result = try context.fetch(fetchRequest)
            
            return result
        }
        catch let error {
            Console.error("Get offline \(String(describing: T.self)): \(error)")
        }
        
        return [T]()
        
    }
    
    public func deleteTable(name:String, predicate:NSPredicate? = nil)
    {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        fetchRequest.predicate = predicate
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            
        } catch let error {
            Console.error(error.localizedDescription)
            // Error Handling
        }
    }
}
