//
//  AddButton.swift
//  To-Do List
//
//  Created by Danila Belyi on 26.06.2023.
//

import UIKit

// MARK: - AddButtonDelegate

protocol AddButtonDelegate: AnyObject {
  func addButtonTapped()
}

// MARK: - AddButton

class AddButton: UIButton {
  private enum Constants {
    static let shadowOpacity: Float = 0.3
    static let shadowRadius: CGFloat = 10
    static let shadowOffsetWidth: CGFloat = 0
    static let shadowOffsetHeight: CGFloat = 8
  }

  weak var delegate: AddButtonDelegate?

  init() {
    super.init(frame: .zero)
    setImage(Images.image(for: .addButton), for: .normal)
    imageView?.contentMode = .scaleAspectFill
    addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    layer.shadowColor = Colors.color(for: .addButtonShadowColor).cgColor
    layer.shadowOpacity = Constants.shadowOpacity
    layer.shadowOffset = CGSize(width: Constants.shadowOffsetWidth, height: Constants.shadowOffsetHeight)
    layer.shadowRadius = Constants.shadowRadius
    layer.masksToBounds = false
    translatesAutoresizingMaskIntoConstraints = false
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc private func addButtonTapped() {
    delegate?.addButtonTapped()
  }
}
