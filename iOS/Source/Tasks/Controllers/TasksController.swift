import UIKit
import DATASource

class TasksController: UITableViewController {
    var fetcher: Fetcher

    let cellIdentifier = String(describing: UITableViewCell.self)

    lazy var dataSource: DATASource = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "offlineDeleted == false")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true)]
        let dataSource = DATASource(tableView: self.tableView!, cellIdentifier: self.cellIdentifier, fetchRequest: fetchRequest, mainContext: self.fetcher.userInterfaceContext) { cell, item, indexPath in
            let cell = cell as! TaskCell
            let item = item as! Task
            cell.item = item
        }

        dataSource.delegate = self

        return dataSource
    }()

    init(style: UITableViewStyle = .plain, fetcher: Fetcher) {
        self.fetcher = fetcher

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self.dataSource
        self.tableView.register(TaskCell.self, forCellReuseIdentifier: self.cellIdentifier)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTask))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.edit))

        self.fetcher.syncTasks()
    }

    func edit() {
        self.setEditing(!self.isEditing, animated: true)
    }

    func addTask() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        let date = dateFormatter.string(from: Date())
        self.fetcher.addTask(named: "Local task " + date)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.dataSource.object(indexPath) as! Task
        self.fetcher.toggleCompleted(item: item)

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { action, indexPath in            
            let item = self.dataSource.objectAtIndexPath(indexPath) as! Task
            self.fetcher.deleteTask(item: item)
        }

        return [delete]
    }
}

extension TasksController: DATASourceDelegate {
    func dataSource(_ dataSource: DATASource, tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }
}
