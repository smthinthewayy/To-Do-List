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

  private let tasksListHeaderView = TasksListHeaderView()

  private var tasks: [Task] = []

  private var showingTasks: [Task] = []

  private enum Constants {
    static let estimatedRowHeight: CGFloat = 56
    static let cornerRadius: CGFloat = 16
    static let cellIdentifier: String = "TasksListItemCell"
    static let newCellIdentifier: String = "NewTaskCell"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    fileCache.loadFromJSON(from: "tasks") { _ in }
    getTasks()
    initShowingTasks()
    setupView()
    setupDelegates()
    setupTasksList()
    setupAddButton()
  }

  override func viewWillTransition(to _: CGSize, with _: UIViewControllerTransitionCoordinator) {
    tasksList.reloadData()
  }

  private func setupShowingTasks() {
    getTasks()
    showingTasks = hideButtonIsActive() ? tasks : tasks.filter { $0.isDone == false }
    updateCompletedTasksLabel()
    UIView.transition(with: tasksList, duration: 0.2, options: .transitionCrossDissolve, animations: {
      self.tasksList.reloadData()
    }, completion: nil)
  }

  private func setupTasksList() {
    view.addSubview(tasksList)
    NSLayoutConstraint.activate([
      tasksList.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tasksList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tasksList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tasksList.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  private func setupView() {
    view.backgroundColor = Colors.color(for: .backPrimary)
    title = "Мои дела"
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 0)
  }

  private func setupDelegates() {
    addButton.delegate = self
    tasksList.dataSource = self
    tasksList.delegate = self
    taskDetailsVC.delegate = self
    tasksListHeaderView.delegate = self
  }

  private func setupAddButton() {
    view.addSubview(addButton)
    NSLayoutConstraint.activate([
      addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
    ])
  }

  private func getTasks() {
    tasks = fileCache.tasks
  }

  private func initShowingTasks() {
    showingTasks = tasks
    updateCompletedTasksLabel()
  }

  private func hideButtonIsActive() -> Bool {
    tasksListHeaderView.hideButton.titleLabel?.text == "Скрыть"
  }

  private func updateCompletedTasksLabel() {
    counterOfCompletedTasks = tasks.filter { $0.isDone == true }.count
    tasksListHeaderView.counterOfCompletedTasksLabel.text = "Выполнено — \(counterOfCompletedTasks)"
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

    if indexPath.row == 0 {
      maskPath = UIBezierPath(
        roundedRect: cell.bounds,
        byRoundingCorners: [.topLeft, .topRight],
        cornerRadii: CGSize(width: 16, height: 16)
      )
    }

    if indexPath.row == tasks.count {
      maskPath = UIBezierPath(
        roundedRect: cell.bounds,
        byRoundingCorners: [.bottomLeft, .bottomRight],
        cornerRadii: CGSize(width: 16, height: 16)
      )
    }

    let shape = CAShapeLayer()
    shape.path = maskPath.cgPath
    cell.layer.mask = shape
  }

  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return showingTasks.count + 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: Constants.cellIdentifier,
      for: indexPath
    ) as? TaskCell
    else { return UITableViewCell() }
    guard let newCell = tableView.dequeueReusableCell(
      withIdentifier: Constants.newCellIdentifier,
      for: indexPath
    ) as? NewTaskCell
    else { return UITableViewCell() }

    cell.delegate = self
    if indexPath.row <= showingTasks.count - 1 {
      cell.configure(with: showingTasks[indexPath.row])
    }

    return indexPath.row == showingTasks.count ? newCell : cell
  }
}

// MARK: UITableViewDelegate

extension TaskListVC: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let taskDetailsVC = TaskDetailsVC()
    taskDetailsVC.delegate = self

    if indexPath.row <= showingTasks.count - 1 {
      let selectedTask = showingTasks[indexPath.row]
      taskDetailsVC.selectedTask = selectedTask
      taskDetailsVC.taskDetailsView.refreshView()
    }

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

  func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
    return tasksListHeaderView
  }

  func tableView(_: UITableView,
                 leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
  {
    guard !showingTasks.isEmpty else {
      return nil
    }

    let action = UIContextualAction(
      style: .normal,
      title: nil,
      handler: { [weak self] _, _, _ in
        var task = self?.showingTasks[indexPath.row]
        task?.isDone.toggle()
        self?.saveTask(task!)
      }
    )

    action.image = Images.image(for: .circleCheckmark)
    action.backgroundColor = Colors.color(for: .green)

    return UISwipeActionsConfiguration(actions: [action])
  }

  func tableView(_: UITableView,
                 trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
  {
    guard !showingTasks.isEmpty else {
      return nil
    }

    let openDetailsAction = UIContextualAction(
      style: .normal,
      title: nil,
      handler: { [weak self] _, _, _ in
        let selectedTask = self?.showingTasks[indexPath.row]
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
        self?.deleteTask(self?.showingTasks[indexPath.row].id ?? "")
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
    _ = fileCache.delete(id)
    fileCache.saveToJSON(to: "tasks") { _ in }
    setupShowingTasks()
  }

  func saveTask(_ task: Task) {
    _ = fileCache.add(task)
    fileCache.saveToJSON(to: "tasks") { _ in }
    setupShowingTasks()
  }
}

// MARK: TaskCellDelegate

extension TaskListVC: TaskCellDelegate {
  func taskCellDidToggleStatusButton(_ taskCell: TaskCell) {
    guard let indexPath = tasksList.indexPath(for: taskCell) else { return }
    var selectedTask = showingTasks[indexPath.row]
    selectedTask.isDone.toggle()
    saveTask(selectedTask)
  }
}

// MARK: TasksListHeaderViewDelegate

extension TaskListVC: TasksListHeaderViewDelegate {
  func hideButtonTapped(_ sender: UIButton) {
    if hideButtonIsActive() {
      showingTasks = tasks.filter { $0.isDone == false }
      sender.setTitle("Показать", for: .normal)
    } else {
      showingTasks = tasks
      sender.setTitle("Скрыть", for: .normal)
    }
    UIView.transition(with: tasksList, duration: 0.3, options: .transitionFlipFromRight, animations: {
      self.tasksList.reloadData()
    }, completion: nil)
  }
}
