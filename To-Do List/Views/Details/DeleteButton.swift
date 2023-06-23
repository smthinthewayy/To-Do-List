//
//  DeleteButton.swift
//  To-Do List
//
//  Created by Danila Belyi on 20.06.2023.
//

import UIKit

// MARK: - DeleteButtonDelegate

protocol DeleteButtonDelegate: AnyObject {
  func deleteButtonTapped()
}

// MARK: - DeleteButton

class DeleteButton: UIButton {
  weak var delegate: DeleteButtonDelegate?

  init() {
    super.init(frame: .zero)
    backgroundColor = Colors.color(for: .backSecondary)
    setTitle("Удалить", for: .normal)
    setTitleColor(Colors.color(for: .red), for: .normal)
    isEnabled = false
    setTitleColor(Colors.color(for: .labelTertiary), for: .disabled)
    layer.cornerRadius = Constants.cornerRadius
    addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    translatesAutoresizingMaskIntoConstraints = false
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func deleteButtonTapped() {
    delegate?.deleteButtonTapped()
  }

  private enum Constants {
    static let cornerRadius: CGFloat = 16
  }
}
