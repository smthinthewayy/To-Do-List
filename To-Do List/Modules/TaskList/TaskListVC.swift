//
//  TaskListVC.swift
//  To-Do List
//
//  Created by Danila Belyi on 26.06.2023.
//

import UIKit

// MARK: - TaskListVC

class TaskListVC: UIViewController {
  private let tasksList = TasksList()

  private let addButton = AddButton()

  private let taskDetailsVC = TaskDetailsVC()

  private var fileCache = FileCache()

  private var counterOfCompletedTasks: Int = 0

  private let counterOfCompletedTasksLabel: UILabel = {
    let label = UILabel()
    label.text = "Выполнено — 0"
    label.font = Fonts.font(for: .subhead)
    label.textColor = Colors.color(for: .labelTertiary)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var hideButton: UIButton = {
    let button = UIButton()
    button.setTitle("Скрыть", for: .normal)
    button.setTitleColor(Colors.color(for: .blue), for: .normal)
    button.titleLabel?.font = Fonts.font(for: .mediumSubhead)
    button.addTarget(self, action: #selector(hideButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private var tasks: [Task] = [] {
    didSet {
      counterOfCompletedTasks = tasks.filter { $0.isDone == true }.count
      counterOfCompletedTasksLabel.text = "Выполнено — \(counterOfCompletedTasks)"
      tasksList.reloadData()
    }
  }

  private var allTasks: [Task] = []

  private enum Constants {
    static let estimatedRowHeight: CGFloat = 56
    static let cornerRadius: CGFloat = 16
    static let cellIdentifier: String = "TasksListItemCell"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    fileCache.loadFromJSON(from: "tasks") { _ in }
    getTasks()
    view.backgroundColor = Colors.color(for: .backPrimary)
    title = "Мои дела"
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 0)

    addButton.delegate = self
    tasksList.dataSource = self
    tasksList.delegate = self
    taskDetailsVC.delegate = self

    view.addSubview(tasksList)
    NSLayoutConstraint.activate([
      tasksList.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tasksList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tasksList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tasksList.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    view.addSubview(addButton)
    NSLayoutConstraint.activate([
      addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
    ])
  }

  @objc private func hideButtonTapped(_ sender: UIButton) {
    if sender.titleLabel?.text == "Скрыть" {
      allTasks = tasks
      tasks = tasks.filter { $0.isDone == false }
      counterOfCompletedTasks = allTasks.filter { $0.isDone == true }.count
      counterOfCompletedTasksLabel.text = "Выполнено — \(counterOfCompletedTasks)"
      sender.setTitle("Показать", for: .normal)
    } else {
      tasks = allTasks
      sender.setTitle("Скрыть", for: .normal)
    }
    UIView.transition(with: tasksList, duration: 0.3, options: .transitionFlipFromRight, animations: {
      self.tasksList.reloadData()
    }, completion: nil)
  }

  private func getTasks() {
    tasks = fileCache.tasks
  }
}

// MARK: AddButtonDelegate

extension TaskListVC: AddButtonDelegate {
  func addButtonTapped() {
    let taskDetailsVC = TaskDetailsVC()
    taskDetailsVC.delegate = self
    let taskDetailsNC = UINavigationController(rootViewController: taskDetailsVC)
    present(taskDetailsNC, animated: true, completion: nil)
  }
}

// MARK: UITableViewDataSource

extension TaskListVC: UITableViewDataSource {
  func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    var maskPath = UIBezierPath(
      roundedRect: cell.bounds,
      byRoundingCorners: [.topLeft, .topRight],
      cornerRadii: CGSize(width: 0, height: 0)
    )

    if indexPath.row == 0 || indexPath.row == tasks.count - 1 {
      maskPath = UIBezierPath(
        roundedRect: cell.bounds,
        byRoundingCorners: [.topLeft, .topRight],
        cornerRadii: CGSize(width: 16, height: 16)
      )
    }

    let shape = CAShapeLayer()
    shape.path = maskPath.cgPath
    cell.layer.mask = shape
  }

  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return tasks.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? TaskCell
    else { return UITableViewCell() }

    cell.delegate = self

    cell.configure(with: tasks[indexPath.row])

    return cell
  }
}

// MARK: UITableViewDelegate

extension TaskListVC: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let selectedTask = tasks[indexPath.row]
    let taskDetailsVC = TaskDetailsVC()
    taskDetailsVC.delegate = self
    taskDetailsVC.selectedTask = selectedTask
    taskDetailsVC.taskDetailsView.refreshView()

    let taskDetailsNC = UINavigationController(rootViewController: taskDetailsVC)
    present(taskDetailsNC, animated: true, completion: nil)
  }

  func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }

  func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
    56
  }

  func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
    return 40
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection _: Int) -> UIView? {
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))

    let cell = UIView()
    cell.translatesAutoresizingMaskIntoConstraints = false

    headerView.addSubview(cell)
    NSLayoutConstraint.activate([
      cell.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
      cell.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
      cell.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
      cell.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
    ])

    cell.addSubview(counterOfCompletedTasksLabel)
    NSLayoutConstraint.activate([
      counterOfCompletedTasksLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
      counterOfCompletedTasksLabel.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16),
    ])

    cell.addSubview(hideButton)
    NSLayoutConstraint.activate([
      hideButton.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
      hideButton.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16),
    ])

    return headerView
  }

  func tableView(_: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    guard !tasks.isEmpty else {
      return nil
    }

    let action = UIContextualAction(
      style: .normal,
      title: nil,
      handler: { [weak self] _, _, _ in
        self?.tasks[indexPath.row].isDone.toggle()
      }
    )

    action.image = Images.image(for: .circleCheckmark)
    action.backgroundColor = Colors.color(for: .green)

    return UISwipeActionsConfiguration(actions: [action])
  }

  func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    guard !tasks.isEmpty else {
      return nil
    }

    let openDetailsAction = UIContextualAction(
      style: .normal,
      title: nil,
      handler: { [weak self] _, _, _ in
        let selectedTask = self?.tasks[indexPath.row]
        let taskDetailsVC = TaskDetailsVC()
        taskDetailsVC.delegate = self
        taskDetailsVC.selectedTask = selectedTask
        taskDetailsVC.taskDetailsView.refreshView()
        let taskDetailsNC = UINavigationController(rootViewController: taskDetailsVC)
        self?.present(taskDetailsNC, animated: true, completion: nil)
      }
    )
    openDetailsAction.image = Images.image(for: .circleInfo)
    openDetailsAction.backgroundColor = Colors.color(for: .grayLight)

    let deleteAction = UIContextualAction(
      style: .normal,
      title: nil,
      handler: { [weak self] _, _, _ in
        self?.deleteTask(self?.tasks[indexPath.row].id ?? "")
      }
    )

    deleteAction.image = Images.image(for: .trash)
    deleteAction.backgroundColor = Colors.color(for: .red)

    return UISwipeActionsConfiguration(actions: [deleteAction, openDetailsAction])
  }
}

// MARK: TaskDetailsVCDelegate

extension TaskListVC: TaskDetailsVCDelegate {
  func deleteTask(_ id: String) {
    let _ = fileCache.delete(id)
    getTasks()
    fileCache.saveToJSON(to: "tasks") { _ in }
  }

  func saveTask(_ task: Task) {
    let _ = fileCache.add(task)
    fileCache.saveToJSON(to: "tasks") { _ in }
    getTasks()
  }
}

// MARK: TaskCellDelegate

extension TaskListVC: TaskCellDelegate {
  func taskCellDidToggleStatusButton(_ taskCell: TaskCell) {
    // обработать случай если indexPath окажется больше чем тасок
    guard let indexPath = tasksList.indexPath(for: taskCell) else { return }
    var selectedTask = tasks[indexPath.row]
    selectedTask.isDone.toggle()
    saveTask(selectedTask)
  }
}
