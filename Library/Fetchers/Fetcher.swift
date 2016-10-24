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
