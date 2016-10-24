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
}
