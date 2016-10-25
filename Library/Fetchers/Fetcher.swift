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
        self.submitPendingChanges {
            let remoteJSON = try! JSON.from("remote.json") as! [[String: Any]]
            let predicate = NSPredicate(format: "synced == true")
            Sync.changes(remoteJSON, inEntityNamed: "Task", predicate: predicate, dataStack: self.dataStack, completion: nil)
        }
    }

    func submitPendingChanges(completion: @escaping () -> Void) {
        self.dataStack.performInNewBackgroundContext { backgroundContext in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
            request.predicate = NSPredicate(format: "synced == false")
            let items = try! backgroundContext.fetch(request) as! [Task]
            for item in items {
                item.remoteID = UUID().uuidString
                item.synced = true
            }
            try! backgroundContext.save()

            completion()
        }
    }

    func addTask(named name: String) {
        self.dataStack.performInNewBackgroundContext { backgroundContext in
            let newTask = NSEntityDescription.insertNewObject(forEntityName: "Task", into: backgroundContext) as! Task
            newTask.localID = UUID().uuidString 
            newTask.completed = false
            newTask.createdDate = Date()
            newTask.name = name
            newTask.synced = false

            try! backgroundContext.save()
        }
    }

    func toggleCompleted(item: Task) {
        self.dataStack.performInNewBackgroundContext { backgroundContext in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
            request.predicate = NSPredicate(format: "localID == %@", item.localID)
            let item = try! backgroundContext.fetch(request).first as! Task
            item.completed = !item.completed
            item.synced = false

            try! backgroundContext.save()
        }
    }
}
