// ___FILEHEADER___

import CoreData
import Foundation

public protocol CoreDataStorage {
    var mainContext: NSManagedObjectContext { get }
    func performBackgroundTaskAndSave(_ block: @escaping (NSManagedObjectContext) -> Void)
    func clean()
    func execute(deleteRequest: NSBatchDeleteRequest)
}

final class CoreDataStack: CoreDataStorage {
    private struct Constants {
        static let dataModelName = "___PACKAGENAME___"
    }
    
    static let shared: CoreDataStack = {
        let persistentContainer = NSPersistentContainer(name: Constants.dataModelName)
        return CoreDataStack(persistentContainer: persistentContainer)
    }()
    
    private let persistentContainer: NSPersistentContainer
    
    var mainContext: NSManagedObjectContext { persistentContainer.viewContext }
    private let backgroundContext: NSManagedObjectContext
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.persistentContainer.loadPersistentStores(completionHandler: { _, error in
            guard let error = error as NSError? else { return }
            fatalError("Unresolved error: \(error), \(error.userInfo)")
        })
        backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        mainContext.automaticallyMergesChangesFromParent = true
        mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

extension CoreDataStack {
    func performBackgroundTaskAndSave(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = backgroundContext
        context.perform { [weak self] in
            block(context)
            guard context.hasChanges else { return }
            do {
                try context.save()
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }
    
    func execute(deleteRequest: NSBatchDeleteRequest) {
        backgroundContext.perform {
            do {
                let deleteResult = try self.backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
                guard let objectIDArray = deleteResult?.result else { return }
                // If some objects were loaded into memory - we should nootify contexts that it should be refreshed after batch delete request
                // https://developer.apple.com/library/archive/featuredarticles/CoreData_Batch_Guide/BatchDeletes/BatchDeletes.html#//apple_ref/doc/uid/TP40016086-CH3-SW1
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: objectIDArray], into: [self.mainContext])
            } catch {
                assertionFailure("Can't remove data from Core Data")
            }
        }
    }
}

extension CoreDataStack {
    func clean() {
        persistentContainer.persistentStoreCoordinator.perform {
            self.persistentContainer.managedObjectModel.entities.forEach { entityDescription in
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityDescription.name!)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try self.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: self.mainContext)
                } catch {
                    assertionFailure("Can't remove data from Core Data")
                }
            }
            
            self.mainContext.perform { self.mainContext.reset() }
            self.backgroundContext.perform { self.backgroundContext.reset() }
        }
    }
}
