import UIKit
import DATASource

class TasksController: UITableViewController {
    var fetcher: Fetcher

    let cellIdentifier = String(describing: UITableViewCell.self)

    lazy var dataSource: DATASource = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true)]
        let dataSource = DATASource(tableView: self.tableView!, cellIdentifier: self.cellIdentifier, fetchRequest: fetchRequest, mainContext: self.fetcher.userInterfaceContext) { cell, item, indexPath in
            let cell = cell as! TaskCell
            let item = item as! Task
            cell.item = item
        }

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

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))

        self.fetcher.syncTasks()
    }

    func addTask() {
        let alertController = UIAlertController(title: "Task title", message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Task title"
            textField.clearButtonMode = .always
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { alert in
            let titleTextField = alertController.textFields![0] as UITextField
            let taskName = titleTextField.text ?? ""
            self.fetcher.addTask(named: taskName)
        }
        alertController.addAction(saveAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.preferredAction = saveAction

        self.present(alertController, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.dataSource.object(indexPath) as! Task
        self.fetcher.toggleCompleted(item: item)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
