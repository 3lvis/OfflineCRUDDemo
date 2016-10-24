import UIKit
import DATASource

class ItemsController: UITableViewController {
    var fetcher: Fetcher

    let cellIdentifier = String(describing: UITableViewCell.self)

    lazy var dataSource: DATASource = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true)]
        let dataSource = DATASource(tableView: self.tableView!, cellIdentifier: self.cellIdentifier, fetchRequest: fetchRequest, mainContext: self.fetcher.userInterfaceContext) { cell, item, indexPath in
            let cell = cell as! ItemCell
            let item = item as! Item
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
        self.tableView.register(ItemCell.self, forCellReuseIdentifier: self.cellIdentifier)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
    }

    func addItem() {
        self.fetcher.addItem(named: "My task item")
    }
}
