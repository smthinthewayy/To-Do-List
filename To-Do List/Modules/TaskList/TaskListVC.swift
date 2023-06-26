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

//  private var tasks: [Task] = [] {
//    didSet {
//      tasksList.reloadData()
//    }
//  }

  private var tasks: [Task] = [
    Task(text: "Купить сыр", createdAt: .now, importance: .normal, isDone: false),
    Task(text: "Сделать пиццу", createdAt: .now, importance: .normal, isDone: true),
    Task(text: "Погладить котиков", createdAt: .now, deadline: .now + 24 * 60 * 60, importance: .important, isDone: false),
    Task(text: "Покормить собачек", createdAt: .now, importance: .normal, isDone: true),
    Task(text: "Пощупать капибару", createdAt: .now, deadline: .now + 24 * 60 * 60 * 3, importance: .low, isDone: false),
    Task(text: "Сделать зарядку", createdAt: .now, importance: .normal, isDone: false),
    Task(text: "Вкусно позавтракать и бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла ", createdAt: .now, importance: .normal, isDone: false),
  ]

  private enum Constants {
    static let estimatedRowHeight: CGFloat = 56
    static let cornerRadius: CGFloat = 16
    static let cellIdentifier: String = "TasksListItemCell"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Colors.color(for: .backPrimary)
    title = "Мои дела"
    navigationController?.navigationBar.prefersLargeTitles = true

    addButton.delegate = self
    tasksList.dataSource = self
    tasksList.delegate = self

    view.addSubview(tasksList)
    NSLayoutConstraint.activate([
      tasksList.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tasksList.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      tasksList.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
      tasksList.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
    
    view.addSubview(addButton)
    NSLayoutConstraint.activate([
      addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
    ])
  }
}

// MARK: AddButtonDelegate

extension TaskListVC: AddButtonDelegate {
  func addButtonTapped() {
    let taskDetailsVC = TaskDetailsVC()
    let taskDetailsNC = UINavigationController(rootViewController: taskDetailsVC)
    present(taskDetailsNC, animated: true, completion: nil)
  }
}

// MARK: UITableViewDataSource

extension TaskListVC: UITableViewDataSource {
  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return tasks.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? TaskCell
    else { return UITableViewCell() }

    cell.configure(with: tasks[indexPath.row])

    return cell
  }
}

// MARK: UITableViewDelegate

extension TaskListVC: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }

  func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    56
  }
}
