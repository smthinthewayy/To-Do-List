//
//  TasksListHeaderView.swift
//  To-Do List
//
//  Created by Danila Belyi on 29.06.2023.
//

import UIKit

// MARK: - TasksListHeaderViewDelegate

protocol TasksListHeaderViewDelegate: AnyObject {
  func hideButtonTapped(_ sender: UIButton)
}

// MARK: - TasksListHeaderView

class TasksListHeaderView: UIView {
  let counterOfCompletedTasksLabel: UILabel = {
    let label = UILabel()
    label.text = "Выполнено — 0"
    label.font = Fonts.font(for: .subhead)
    label.textColor = Colors.color(for: .labelTertiary)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  lazy var hideButton: UIButton = {
    let button = UIButton()
    button.setTitle("Скрыть", for: .normal)
    button.setTitleColor(Colors.color(for: .blue), for: .normal)
    button.titleLabel?.font = Fonts.font(for: .mediumSubhead)
    button.addTarget(self, action: #selector(hideButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  weak var delegate: TasksListHeaderViewDelegate?

  override init(frame: CGRect) {
    super.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: 40))

    addSubview(counterOfCompletedTasksLabel)
    NSLayoutConstraint.activate([
      counterOfCompletedTasksLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
      counterOfCompletedTasksLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
    ])

    addSubview(hideButton)
    NSLayoutConstraint.activate([
      hideButton.centerYAnchor.constraint(equalTo: centerYAnchor),
      hideButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
    ])
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc private func hideButtonTapped(_ sender: UIButton) {
    delegate?.hideButtonTapped(sender)
  }
}
