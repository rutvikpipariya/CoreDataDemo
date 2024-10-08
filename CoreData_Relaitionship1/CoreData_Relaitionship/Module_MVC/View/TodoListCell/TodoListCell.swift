import UIKit

class TodoListCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var checkMarkButton: UIButton!
    @IBOutlet weak var taskNameLabel: UILabel!

    //MARK: - Override Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        self.checkMarkButton.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Cuustom Function
    func configure(with task: TodoModel, isSelected: Bool, target: Any?, action: Selector) {
        taskNameLabel.text = task.taskname
        checkMarkButton.isHidden = false
        checkMarkButton.isHidden = !isSelected
        checkMarkButton.setImage(isSelected ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle"), for: .normal)
        checkMarkButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
