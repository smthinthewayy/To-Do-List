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
    print("saveTapped")
  }

  func deleteButtonTapped() {
    print("deleteButtonTapped")
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
    print("\(sender.isOn)")
  }

  func segmentControlTapped(_ sender: UISegmentedControl) {
    print("\(sender.selectedSegmentIndex)")
  }
}
