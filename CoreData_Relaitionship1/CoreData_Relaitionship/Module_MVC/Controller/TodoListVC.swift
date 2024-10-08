import UIKit

class TodoListVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var taskDataTableView: UITableView!
    
    //MARK: - Variables
    var tasks: [TodoModel] = []
    var selectedTaskIDs: Set<String> = []
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
    
    //MARK: - Button Actions
    @IBAction func addTaskButtonTapped(_ sender: UIButton) {
        guard let taskName = taskTextField.text, !taskName.isEmpty else { return }
        DatabaseService.shared.saveTask(taskName: taskName)
        taskTextField.text = ""
        self.fetchTasks()
    }
    
    @IBAction func deleteSelectedTasks(_ sender: UIButton) {
        guard !selectedTaskIDs.isEmpty else { return }
        DatabaseService.shared.deleteTasks(ids: selectedTaskIDs)
        fetchTasks()
        selectedTaskIDs.removeAll()
        for cell in taskDataTableView.visibleCells {
            if let todoCell = cell as? TodoListCell {
                todoCell.checkMarkButton.isHidden = true
            }
        }
    }
    
    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            for cell in taskDataTableView.visibleCells {
                if let todoCell = cell as? TodoListCell {
                    todoCell.checkMarkButton.isHidden = false
                }
            }
        }
    }
    
    @objc func checkMarkButtonTapped(_ sender: UIButton) {
        let taskIndex = sender.tag
        let task = tasks[taskIndex]
        if selectedTaskIDs.contains(task.id) {
            selectedTaskIDs.remove(task.id)
        } else {
            selectedTaskIDs.insert(task.id)
        }
        taskDataTableView.reloadRows(at: [IndexPath(row: taskIndex, section: 0)], with: .none)
        if selectedTaskIDs.isEmpty {
            for cell in taskDataTableView.visibleCells {
                if let todoCell = cell as? TodoListCell {
                    todoCell.checkMarkButton.isHidden = true
                }
            }
        }
    }
    
    //MARK: - Custom Functions
    private func initialSetup() {
        self.taskDataTableView.setupTable(identifier: TodoListCell.identifier, vc: self)
        self.fetchTasks()
        self.addLongPressGesture()
    }
    
    private func fetchTasks() {
        DatabaseService.shared.fetchTasks { [weak self] tasks, error in
            if let error = error {
                self?.showAlert(message: "Error fetching tasks: \(error.localizedDescription)")
                return
            }
            self?.tasks = tasks ?? []
            DispatchQueue.main.async {
                self?.taskDataTableView.reloadData()
            }
        }
    }
    
    private func addLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        taskDataTableView.addGestureRecognizer(longPressGesture)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension TodoListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: TodoListCell.identifier, for: indexPath) as? TodoListCell {
            let task = tasks[indexPath.row]
            let isSelected = selectedTaskIDs.contains(task.id)
            cell.configure(with: task, isSelected: isSelected, target: self, action: #selector(checkMarkButtonTapped))
            cell.checkMarkButton.tag = indexPath.row
            cell.checkMarkButton.isHidden = selectedTaskIDs.isEmpty
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        if selectedTaskIDs.contains(task.id) {
            selectedTaskIDs.remove(task.id)
        } else {
            selectedTaskIDs.insert(task.id)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
