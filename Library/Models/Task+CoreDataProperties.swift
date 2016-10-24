import Foundation
import CoreData

extension Task {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: Task.entityName);
    }

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var completed: Bool
    @NSManaged public var createdDate: Date
    @NSManaged public var synced: Bool
}
