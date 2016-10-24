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

    // Syncs all the tasks that have the synced flag as true.
    // In Core Data we've set synced to be true by default so all remote items will be inserted as synced == true.
    // The problem here is that if we mark "Server task 1" as completed, it will be marked as synced == false, then in the next Sync
    // "Server task 1" will be inserted again. Which is dumb.
    func syncTasks() {
        let remoteJSON = try! JSON.from("remote.json") as! [[String: Any]]
        let predicate = NSPredicate(format: "synced == true")
        Sync.changes(remoteJSON, inEntityNamed: "Task", predicate: predicate, dataStack: self.dataStack, completion: nil)
    }

    func addTask(named name: String) {
        self.dataStack.performInNewBackgroundContext { backgroundContext in
            let newTask = NSEntityDescription.insertNewObject(forEntityName: "Task", into: backgroundContext) as! Task
            newTask.completed = false
            newTask.createdDate = Date()
            newTask.id = UUID().uuidString
            newTask.name = name
            newTask.synced = false

            try! backgroundContext.save()
        }
    }

    func toggleCompleted(item: Task) {
        self.dataStack.performInNewBackgroundContext { backgroundContext in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
            request.predicate = NSPredicate(format: "id == %@", item.id)
            let item = try! backgroundContext.fetch(request).first as! Task
            item.completed = !item.completed
            item.synced = false

            try! backgroundContext.save()
        }
    }
}
