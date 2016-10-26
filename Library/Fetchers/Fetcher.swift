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
            // Only sync tasks that existing in the backend.
            // The backend changes will overwrite any local state of remote items
            // since the true lives on the backend and also because you should make
            // sure to send your local changes to the backend before syncing the elements.
            let remoteJSON = try! JSON.from("remote.json") as! [[String: Any]]
            let predicate = NSPredicate(format: "remoteID != %@", NSNull())
            let sync = Sync(changes: remoteJSON, inEntityNamed: "Task", predicate: predicate, dataStack: self.dataStack)
            sync.delegate = self
            sync.start()
        }
    }

    /// This is the method that you would usually call to send your local changes to the backend
    /// if the task has a remoteID you'll update the contents in the backend, it it doesn't have a remoteID
    /// you'll create the task in the backend. Finally if it has a "deleted" equals true, then you'll delete it
    /// from the backend.
    func submitPendingChanges(completion: @escaping () -> Void) {
        self.dataStack.performInNewBackgroundContext { backgroundContext in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
            request.predicate = NSPredicate(format: "synced == false")

            // Create, update or delete in backend. After any of this operations
            // are completed change the synced flag to true.
            let items = try! backgroundContext.fetch(request) as! [Task]
            print(items.map { $0.localID })

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

extension Fetcher: SyncDelegate {
    func sync(_ sync: Sync, willInsert json: [String: Any], in entityNamed: String, parent: NSManagedObject?) -> [String: Any] {
        var newJSON = json
        newJSON["localID"] = UUID().uuidString

        return newJSON
    }
}
