//
//  TaskDetailsVC.swift
//  To-Do List
//
//  Created by Danila Belyi on 17.06.2023.
//

import UIKit

// MARK: - TaskDetailsVCDelegate

protocol TaskDetailsVCDelegate: AnyObject {
  func deleteTask(_ id: String)
  func saveTask(_ task: Task)
}

// MARK: - TaskDetailsVC

class TaskDetailsVC: UIViewController {
  var taskDetailsView = TaskDetailsView()

  private var taskDescription: String = ""

  var selectedTask: Task?

  lazy var cancelButton: UIBarButtonItem = {
    let button = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(cancelTapped))
    button.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.font(for: .body)], for: .normal)
    return button
  }()

  lazy var saveButton: UIBarButtonItem = {
    let button = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(saveTapped))
    button.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.font(for: .headline)], for: .normal)
    button.setTitleTextAttributes(
      [NSAttributedString.Key.foregroundColor: Colors.color(for: .labelTertiary),
       NSAttributedString.Key.font: Fonts.font(for: .headline)],
      for: .disabled
    )
    button.isEnabled = false
    return button
  }()

  var taskAdded: ((Task) -> Void)?

  weak var delegate: TaskDetailsVCDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupTaskDetailsView()
  }

  private func setupNavigationBar() {
    navigationItem.title = "Дело"
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Fonts.font(for: .headline)]
    navigationItem.leftBarButtonItem = cancelButton
    navigationItem.rightBarButtonItem = saveButton
  }

  private func setupTaskDetailsView() {
    view.addSubview(taskDetailsView)
    taskDetailsView.delegate = self
    taskDetailsView.task = selectedTask ?? Task(text: "", createdAt: .now, importance: .important, isDone: false)
    taskDetailsView.refreshView()
    NSLayoutConstraint.activate([
      taskDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      taskDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      taskDetailsView.topAnchor.constraint(equalTo: view.topAnchor),
      taskDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}

// MARK: TaskDetailsViewDelegate

extension TaskDetailsVC: TaskDetailsViewDelegate {
  @objc func cancelTapped() {
    dismiss(animated: true)
  }

  func fetchTaskDescription(_ textView: UITextView) {
    taskDescription = textView.text
  }

  @objc func saveTapped() {
    fetchTaskDescription(taskDetailsView.taskDescriptionTextView)
    taskDetailsView.task.text = taskDescription
    
    
    delegate?.saveTask(taskDetailsView.task)
    
    
    dismiss(animated: true)
  }

  private func showAlert(title: String, message: String?) {
    let alert = UIAlertController(title: title, message: message ?? "unknown error", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }

  func deleteButtonTapped() {
    delegate?.deleteTask(selectedTask?.id ?? "")
    dismiss(animated: true)
    clearView()
//    let fileManager = FileManager.default
//    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//    let fileURL = documentsDirectory.appendingPathComponent("task.json")
//
//    do {
//      try fileManager.removeItem(at: fileURL)
//      dismiss(animated: true)
//      clearView()
//    } catch {
//      showAlert(title: "Не удалось удалить файл", message: error.localizedDescription)
//    }
  }

  private func clearView() {
    taskDetailsView.taskDescriptionTextView.text = "Что надо сделать?"
    taskDetailsView.taskDescriptionTextView.textColor = Colors.color(for: .labelTertiary)
    taskDetailsView.parametersView.importancePicker.selectedSegmentIndex = 2
    taskDetailsView.parametersView.deadlineSwitch.isOn = false
    taskDetailsView.parametersView.deadlineDateButton.isHidden = true
//    taskDetailsView.deleteButton.isEnabled = false
    saveButton.isEnabled = false
  }

  func toggleSaveButton(_ textView: UITextView) {
    if !textView.text.isEmpty {
      saveButton.isEnabled = true
    } else {
      saveButton.isEnabled = false
    }
  }
}

// MARK: ParametersViewDelegate

extension TaskDetailsVC: ParametersViewDelegate {
  func switchTapped(_ sender: UISwitch) {
    if sender.isOn {
      taskDetailsView.task.deadline = .now + 24 * 60 * 60
    } else {
      taskDetailsView.task.deadline = nil
    }
    saveButton.isEnabled = true
  }

  func segmentControlTapped(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0: taskDetailsView.task.importance = .low
    case 2: taskDetailsView.task.importance = .important
    default: taskDetailsView.task.importance = .normal
    }
    saveButton.isEnabled = true
  }

  func dateSelection(_ date: DateComponents?) {
    taskDetailsView.task.deadline = date!.date
    saveButton.isEnabled = true
  }
}
