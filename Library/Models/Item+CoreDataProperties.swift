import Foundation
import CoreData

extension Item {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: Item.entityName);
    }

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var completed: Bool
    @NSManaged public var createdDate: Date
    @NSManaged public var synced: Bool
}
