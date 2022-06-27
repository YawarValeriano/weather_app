import Foundation
import CoreData

class CoreDataManager {
    
    static var shared = CoreDataManager()
    
    func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "WeatherApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Fetch Photos
    
    func fetchSearchHistory<T: NSManagedObject>(_ type: T.Type, request: NSFetchRequest<T>, completion: @escaping(Result<[T], Error>) -> Void) {
        let context = persistentContainer.viewContext
        do {
            let dbSearch = try context.fetch(request)
            completion(.success(dbSearch))
        } catch (let error) {
            completion(.failure(error))
        }
    }
    
    func deleteItem(item: Search, completion: @escaping(Result<Void, Error>) -> Void) {
        let context = persistentContainer.viewContext
        do {
            context.delete(item)
            try context.save()
            completion(.success(()))
        } catch (let error) {
            completion(.failure(error))
        }
    }

}
