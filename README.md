# OfflineCRUDDemo

Demo on how to use Sync in an enviroment where some items would be created locally to be uploaded later to the backend. Local items won't get overwritten by the backend and changes to remote items won't be overwritten.

It also displays how to deal with offline changes and deletions.

All your tasks have a localID and a remoteID, the remoteID is the ID in the backend. We also use a localID since you can create tasks without internet connection and you'll need a primary key for this tasks (to update them, deleted them and so on).

For this functionality we'll require three extra flags: 
 
- `offlineDeleted` (Boolean): Used to track tasks that were deleted while the device didn't have internet connection.
- `synced` (Boolean): Used to track offline changes, such as completion or title changes.
- `localID` (String): We need all tasks to have a unique ID, without caring if it's a remote or local task.
 
## Sync

Before syncing we'll fetch all the local tasks and upload them to our server, after doing this, we'll set the `synced` flag to `true`. Now all the synced tasks will have a `remoteID`.

Perform diff only between remote items and local items that have a `remoteID`, meaning locally created items are ignored from the diffing.

- Download remote items (in the example this items are defined in remote.json)
- Insert remote items not found in local database
- Update remote items found in local database
- Remove local items not found in remote list

When you call Sync you'll use the following predicate to tell Sync to only insert, update and delete tasks which `remoteID` is different than `nil`.

```swift
let predicate = NSPredicate(format: "remoteID != %@", NSNull())
let sync = Sync(changes: remoteJSON, inEntityNamed: "Task", predicate: predicate, dataStack: self.dataStack)
sync.delegate = self
sync.start()
```

## Insert

Pressing the "+" button will add a new local task. This task won't be deleted by the Sync method since it's a local task. This task gets created with the `synced` flag as false. This task will try to be uploaded to the server but if that fails it will be queued to be uploaded the next time the device goes online.

## Update
Similar to the insert method with the main difference is that this updates a task instead of creating it. If the update fails it gets queued until the next sync happens.

## Delete


## Unique ID

To sync local and remote changes we need all the tasks to have a unique ID (`localID`), for this we'll use the `SyncDelegate`.

```swift
extension Fetcher: SyncDelegate {
    func sync(_ sync: Sync, willInsert json: [String: Any], in entityNamed: String, parent: NSManagedObject?) -> [String: Any] {
        var newJSON = json
        newJSON["localID"] = UUID().uuidString

        return newJSON
    }
}
```
