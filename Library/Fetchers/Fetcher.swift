import Foundation
import DATAStack
import Sync
import DATASource
import CoreData

class Fetcher {
    var dataStack: DATAStack

    init(modelName: String) {
        self.dataStack = DATAStack(modelName: modelName)
    }

    var userInterfaceContext: NSManagedObjectContext {
        return self.dataStack.mainContext
    }

    func addItem(named name: String) {
        self.dataStack.performInNewBackgroundContext { backgroundContext in
            let newItem = NSEntityDescription.insertNewObject(forEntityName: "Item", into: backgroundContext) as! Item
            newItem.completed = false
            newItem.createdDate = Date()
            newItem.id = UUID().uuidString
            newItem.name = name
            newItem.synced = false

            try! backgroundContext.save()
        }
    }

    func toggleCompleted(item: Item) {
        self.dataStack.performInNewBackgroundContext { backgroundContext in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
            request.predicate = NSPredicate(format: "id == %@", item.id)
            let item = try! backgroundContext.fetch(request).first as! Item
            item.completed = !item.completed

            try! backgroundContext.save()
        }
    }
}
