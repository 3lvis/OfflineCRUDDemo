import UIKit

class TaskCell: UITableViewCell {
    var item: Task? {
        didSet {
            self.textLabel?.text = self.item?.name

            let isCompleted = self.item?.completed ?? false
            self.accessoryType = isCompleted ? .checkmark : .none
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
