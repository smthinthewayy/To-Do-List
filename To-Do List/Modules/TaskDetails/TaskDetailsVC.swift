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
  func saveTask(_ task: Task, _ flag: Bool)
}

// MARK: - TaskDetailsVC

class TaskDetailsVC: UIViewController {
  private var taskDescription: String = ""

  var taskDetailsView = TaskDetailsView()

  var selectedTask: Task?

  var isNewTask: Bool = false

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

  weak var delegate: TaskDetailsVCDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupTaskDetailsView()
    hideAllExceptTextViewIfNeeded()
  }

  override func viewWillTransition(to _: CGSize, with _: UIViewControllerTransitionCoordinator) {
    hideAllExceptTextViewIfNeeded()
  }

  func hideAllExceptTextViewIfNeeded() {
    UIView.transition(with: taskDetailsView, duration: 0.2, options: .transitionCrossDissolve, animations: { [self] in
      if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        let interfaceOrientation = windowScene.interfaceOrientation
        if interfaceOrientation.isLandscape {
          taskDetailsView.parametersView.isHidden = true
          taskDetailsView.deleteButton.isHidden = true
        } else {
          taskDetailsView.parametersView.isHidden = false
          taskDetailsView.deleteButton.isHidden = false
        }
      }
    }, completion: nil)
  }

  private func setupNavigationBar() {
    navigationItem.title = "Дело"
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Fonts.font(for: .headline)]
    navigationItem.leftBarButtonItem = cancelButton
    navigationItem.rightBarButtonItem = saveButton
  }

  private func setupTaskDetailsView() {
    view.addSubview(taskDetailsView)
    taskDetailsView.deleteButton.isEnabled = !isNewTask
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
    delegate?.saveTask(taskDetailsView.task, isNewTask)
    dismiss(animated: true)
  }

  func deleteButtonTapped() {
    delegate?.deleteTask(selectedTask?.id ?? "")
    dismiss(animated: true)
    clearView()
  }

  private func clearView() {
    taskDetailsView.taskDescriptionTextView.text = "Что надо сделать?"
    taskDetailsView.taskDescriptionTextView.textColor = Colors.color(for: .labelTertiary)
    taskDetailsView.parametersView.importancePicker.selectedSegmentIndex = 2
    taskDetailsView.parametersView.deadlineSwitch.isOn = false
    taskDetailsView.parametersView.deadlineDateButton.isHidden = true
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
    if !isNewTask {
      saveButton.isEnabled = true
    }
  }

  func segmentControlTapped(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0: taskDetailsView.task.importance = .low
    case 2: taskDetailsView.task.importance = .important
    default: taskDetailsView.task.importance = .normal
    }
    if !isNewTask {
      saveButton.isEnabled = true
    }
  }

  func dateSelection(_ date: DateComponents?) {
    taskDetailsView.task.deadline = date!.date
    if !isNewTask {
      saveButton.isEnabled = true
    }
  }
}
