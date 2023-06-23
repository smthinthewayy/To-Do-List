//
//  TodoItemDetailsVC.swift
//  To-Do List
//
//  Created by Danila Belyi on 17.06.2023.
//

import UIKit

// MARK: - TodoItemDetailsVC

class TodoItemDetailsVC: UIViewController {
  private let todoItemDetailsView = TodoItemDetailsView()
  private let fileCache = FileCache()
  private var item = TodoItem(text: "", createdAt: .now, importance: Importance.normal, isDone: false)

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

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = "Дело"
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Fonts.font(for: .headline)]
    navigationItem.leftBarButtonItem = cancelButton
    navigationItem.rightBarButtonItem = saveButton

    let todoItemDetailsView = TodoItemDetailsView()
    todoItemDetailsView.delegate = self
    view.addSubview(todoItemDetailsView)

    NSLayoutConstraint.activate([
      todoItemDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      todoItemDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      todoItemDetailsView.topAnchor.constraint(equalTo: view.topAnchor),
      todoItemDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}

// MARK: TodoItemDetailsViewDelegate

extension TodoItemDetailsVC: TodoItemDetailsViewDelegate {
  @objc func cancelTapped() {
    print("cancelTapped")
  }

  @objc func saveTapped() {
    item.text = todoItemDetailsView.taskDescription
    let _ = fileCache.add(item)
    fileCache.saveToJSON(to: "task") { error in
      switch error {
      case nil:
        let alert = UIAlertController(title: "Успех", message: "Файл успешно создан", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
      default:
        let alert = UIAlertController(title: "Не удалось сохранить файл", message: error?.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }
    }
  }

  func deleteButtonTapped() {
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsDirectory.appendingPathComponent("task.json")

    do {
      try fileManager.removeItem(at: fileURL)

      let alert = UIAlertController(title: "Успех", message: "Файл успешно удален", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      present(alert, animated: true, completion: nil)
    } catch {
      let alert = UIAlertController(title: "Не удалось удалить файл", message: error.localizedDescription, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      present(alert, animated: true, completion: nil)
    }
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

extension TodoItemDetailsVC: ParametersViewDelegate {
  func switchTapped(_ sender: UISwitch) {
    if sender.isOn {
      item.deadline = .now + 24 * 60 * 60
    } else {
      item.deadline = nil
    }
  }

  func segmentControlTapped(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0: item.importance = .low
    case 2: item.importance = .important
    default: item.importance = .normal
    }
  }

  func dateSelection(_ date: DateComponents?) {
    item.deadline = date!.date
  }
}
