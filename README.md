# OfflineCRUDDemo

Demo on how to use Sync in an enviroment where some items would be created locally to be uploaded later to the backend. Local items won't get overwritten by the backend and changes to remote items won't be overwritten.

It also displays how to deal with offline changes and deletions.

All your tasks have a localID and a remoteID, the remoteID is the ID in the backend. We also use a localID since you can create tasks without internet connection and you'll need a primary key for this tasks (to update them, deleted them and so on).

## Sync

Perform diff only between remote items and local items that have a remoteID, meaning locally created items are ignored from the diffing.

- Download remote items (in the example this items are defined in remote.json)
- Insert remote items not found in local database
- Update remote items found in local database
- Remove local items not found in remote list

When you call Sync you'll use the following predicate to tell Sync to only insert, update and delete tasks which remoteID is different than `nil`.

```swift
let predicate = NSPredicate(format: "remoteID != %@", NSNull())
let sync = Sync(changes: remoteJSON, inEntityNamed: "Task", predicate: predicate, dataStack: self.dataStack)
sync.delegate = self
sync.start()
```

## Insert
WIP.

## Update
WIP.

## Delete
WIP.

## Draft

This wil cause all the local-only tasks to be skipped. Also, we'll use the `SyncDelegate` to make sure that every inserted remote task has also a localID. We do this so it's easy to query all the tasks with a common primary key.

```swift
extension Fetcher: SyncDelegate {
    func sync(_ sync: Sync, willInsert json: [String: Any], in entityNamed: String, parent: NSManagedObject?) -> [String: Any] {
        var newJSON = json
        newJSON["localID"] = UUID().uuidString

        return newJSON
    }
}
```
