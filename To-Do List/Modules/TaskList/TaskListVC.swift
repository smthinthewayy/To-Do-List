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
    Task(text: "Покормить собачек", createdAt: .now, deadline: .now - 24 * 60 * 60, importance: .normal, isDone: true),
    Task(text: "Пощупать капибару", createdAt: .now, importance: .low, isDone: false),
    Task(text: "Сделать зарядку, медитация, холодный душ", createdAt: .now, importance: .important, isDone: false),
    Task(
      text: "Вкусно позавтракать и бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла бла ",
      createdAt: .now,
      deadline: .now + 24 * 60 * 60,
      importance: .important,
      isDone: true
    ),
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
    
//    let customTitleView = UILabel()
//    customTitleView.text = "Мои дела"
//    customTitleView.font = Fonts.font(for: .largeTitle)
//    customTitleView.translatesAutoresizingMaskIntoConstraints = false
//    navigationItem.titleView = customTitleView
    
    addButton.delegate = self
    tasksList.dataSource = self
    tasksList.delegate = self

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
      sender.setTitle("Показать", for: .normal)
    } else {
      sender.setTitle("Скрыть", for: .normal)
    }
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
    
    let label = UILabel()
    label.text = "Выполнено — 5"
    label.font = Fonts.font(for: .subhead)
    label.textColor = Colors.color(for: .labelTertiary)
    label.translatesAutoresizingMaskIntoConstraints = false
    
    let hideButton = UIButton()
    hideButton.setTitle("Скрыть", for: .normal)
    hideButton.setTitleColor(Colors.color(for: .blue), for: .normal)
    hideButton.titleLabel?.font = Fonts.font(for: .mediumSubhead)
    hideButton.addTarget(self, action: #selector(hideButtonTapped), for: .touchUpInside)
    hideButton.translatesAutoresizingMaskIntoConstraints = false
      
    cell.addSubview(label)
    NSLayoutConstraint.activate([
      label.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
      label.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16),
    ])
    
    cell.addSubview(hideButton)
    NSLayoutConstraint.activate([
      hideButton.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
      hideButton.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16),
    ])

//    NSLayoutConstraint.activate([
//      headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
//      headerView.bottomAnchor.constraint(equalTo: tasksList.topAnchor, constant: -12)
//    ])

//    let label = UILabel()
//    label.frame = CGRect(x: 5, y: 5, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
//    label.text = "Notification Times"
//    label.font = .systemFont(ofSize: 16)
//    label.textColor = .yellow

//    headerView.addSubview(label)

    return headerView
  }
}
