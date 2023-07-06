//
//  TaskListVC.swift
//  To-Do List
//
//  Created by Danila Belyi on 26.06.2023.
//

import DTLogger
import UIKit

// MARK: - TaskListVC

class TaskListVC: UIViewController {
  private let tasksList = TasksList()

  private let addButton = AddButton()

  private let taskDetailsVC = TaskDetailsVC()

  private var fileCache = FileCache()

  private var counterOfCompletedTasks: Int = 0

  private let tasksListHeaderView = TasksListHeaderView()

  private let dns = DefaultNetworkingService(
    baseURL: URL(string: "https://beta.mrdekk.ru/todobackend")!,
    bearerToken: "intend"
  )

  private var tasks = Tasks()

  private var showingTasks: [Task] = []

  private enum Constants {
    static let estimatedRowHeight: CGFloat = 56
    static let cornerRadius: CGFloat = 16
    static let cellIdentifier: String = "TasksListItemCell"
    static let newCellIdentifier: String = "NewTaskCell"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    loadTasksFromCache()
    loadTasksFromServer()
    synchronize()
  }

  private func loadTasksFromCache() {
    fileCache.loadFromJSON(from: "tasks") { result in
      switch result {
      case nil:
        SystemLogger.info("Запуск приложения: данные из кэша успешно получены")
      default:
        SystemLogger.info("Запуск приложения: ошибка получения локальных данных из кэша")
      }
    }
  }

  private func loadTasksFromServer() {
    let setup: () -> Void = { [weak self] in
      self?.setupView()
      self?.setupDelegates()
      self?.setupTasksList()
      self?.setupAddButton()
    }

    dns.getTasksList { result in
      switch result {
      case let .success(response):
        self.dns.revision = response.revision
        print(response.list)
        self.tasks.tasks = response.list.map { self.dns.convertToTask(from: $0) }
        SystemLogger.info("Запуск приложения: данные с сервера успешно получены, отображаем их на экране")
        RunLoop.main.perform { setup() }
      case let .failure(error):
        self.tasks.tasks = self.fileCache.tasks
        SystemLogger.error("Запуск приложения: не удалось получить данные с сервера, отображаем данные из кэша. Ошибка: \(error)")
        RunLoop.main.perform { setup() }
      }
    }
  }

  private func synchronize() {
    if tasks.isDirty {
      dns.updateList(tasks.tasks.map { self.dns.convertToNetworkTask(from: $0) }) { result in
        switch result {
        case let .success(response):
//          self.dns.revision = response.revision
          self.fileCache.tasks = response.list.map { self.dns.convertToTask(from: $0) }
          self.tasks.isDirty = false
          SystemLogger.info("Сихронизация данных прошла успешно, isDirty = \(self.tasks.isDirty)")
        case let .failure(error):
          self.tasks.isDirty = true
          SystemLogger
            .error("Ошибка при попытке синхронизировать данные, isDirty = \(self.tasks.isDirty). Ошибка: \(error)")
        }
      }
    }
  }

  private func setupShowingTasks() {
    tasks.tasks = fileCache.tasks
    showingTasks = hideButtonIsActive() ? tasks.tasks : tasks.tasks.filter { $0.isDone == false }
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

  private func initShowingTasks() {
    showingTasks = tasks.tasks
    updateCompletedTasksLabel()
  }

  private func hideButtonIsActive() -> Bool {
    tasksListHeaderView.hideButton.titleLabel?.text == "Скрыть"
  }

  private func updateCompletedTasksLabel() {
    counterOfCompletedTasks = tasks.tasks.filter { $0.isDone == true }.count
    tasksListHeaderView.counterOfCompletedTasksLabel.text = "Выполнено — \(counterOfCompletedTasks)"
  }

  override func viewWillTransition(to _: CGSize, with _: UIViewControllerTransitionCoordinator) {
    tasksList.reloadData()
  }
}

// MARK: AddButtonDelegate

extension TaskListVC: AddButtonDelegate {
  func addButtonTapped() {
    let taskDetailsVC = TaskDetailsVC()
    taskDetailsVC.delegate = self
    taskDetailsVC.isNewTask = true
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

    if indexPath.row == tasks.tasks.count {
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
    taskDetailsVC.isNewTask = true

    if indexPath.row <= showingTasks.count - 1 {
      let selectedTask = showingTasks[indexPath.row]
      taskDetailsVC.selectedTask = selectedTask
      taskDetailsVC.isNewTask = false
      taskDetailsVC.taskDetailsView.refreshView()
    }

    let taskDetailsNC = UINavigationController(rootViewController: taskDetailsVC)
    present(taskDetailsNC, animated: true, completion: nil)
  }

  func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
    UITableView.automaticDimension
  }

  func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
    56
  }

  func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
    40
  }

  func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
    tasksListHeaderView
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
        self?.saveTask(task!, false)
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

    fileCache.saveToJSON(to: "tasks") { result in
      switch result {
      case nil:
        SystemLogger.info("Данные успешно сохранены в кэш")
      default:
        SystemLogger.error("Ошибка при попытке сохранить изменения в кэш")
      }
    }

    dns.deleteTaskFromList(for: id) { result in
      switch result {
      case .failure:
        self.tasks.isDirty = true
        SystemLogger.error("Ошибка при отправке DELETE запроса на удаление задачи на сервер, isDirty = \(self.tasks.isDirty)")
      case .success:
//        self.dns.revision = response.revision
        SystemLogger.info("Отправка DELETE запроса на удаление задачи на сервер прошла успешно, isDirty = \(self.tasks.isDirty)")
      }
    }

    synchronize()
    setupShowingTasks()
  }

  func saveTask(_ task: Task, _ flag: Bool) {
    _ = fileCache.add(task)

    fileCache.saveToJSON(to: "tasks") { result in
      switch result {
      case nil:
        SystemLogger.info("Данные успешно сохранены в кэш")
      default:
        SystemLogger.error("Ошибка при попытке сохранить изменения в кэш")
      }
    }

    if flag {
      dns.addTaskToList(task: dns.convertToNetworkTask(from: task)) { result in
        switch result {
        case .failure:
          self.tasks.isDirty = true
          SystemLogger.error("Ошибка при отправке POST запроса на добавление новой задачи на сервер, isDirty = \(self.tasks.isDirty)")
        case .success:
//          self.dns.revision = response.revision
          SystemLogger.info("Отправка POST запроса на добавление новой задачи на сервер прошла успешно, isDirty = \(self.tasks.isDirty)")
        }
      }
    } else {
      dns.editTask(task: dns.convertToNetworkTask(from: task)) { result in
        switch result {
        case .failure:
          self.tasks.isDirty = true
          SystemLogger
            .error("Ошибка при отправке PUT запроса на изменение задачи на сервер, isDirty = \(self.tasks.isDirty)")
        case .success:
//          self.dns.revision = response.revision
          SystemLogger
            .info("Отправка PUT запроса на изменение задачи на сервер прошла успешно, isDirty = \(self.tasks.isDirty)")
        }
      }
    }

    synchronize()
    setupShowingTasks()
  }
}

// MARK: TaskCellDelegate

extension TaskListVC: TaskCellDelegate {
  func taskCellDidToggleStatusButton(_ taskCell: TaskCell) {
    guard let indexPath = tasksList.indexPath(for: taskCell) else { return }
    var selectedTask = showingTasks[indexPath.row]
    selectedTask.isDone.toggle()
    saveTask(selectedTask, false)
  }
}

// MARK: TasksListHeaderViewDelegate

extension TaskListVC: TasksListHeaderViewDelegate {
  func hideButtonTapped(_ sender: UIButton) {
    if hideButtonIsActive() {
      showingTasks = tasks.tasks.filter { $0.isDone == false }
      sender.setTitle("Показать", for: .normal)
    } else {
      showingTasks = tasks.tasks
      sender.setTitle("Скрыть", for: .normal)
    }
    UIView.transition(with: tasksList, duration: 0.3, options: .transitionFlipFromRight, animations: {
      self.tasksList.reloadData()
    }, completion: nil)
  }
}
