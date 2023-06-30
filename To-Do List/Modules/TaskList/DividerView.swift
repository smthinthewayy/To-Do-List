//
//  DividerView.swift
//  To-Do List
//
//  Created by Danila Belyi on 26.06.2023.
//

import UIKit

class DividerView: UIView {
  private enum Constants {
    static let dividerViewHeight: CGFloat = 0.5
    static let dividerViewWidth: CGFloat = 311
  }

  override init(frame _: CGRect) {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    heightAnchor.constraint(equalToConstant: Constants.dividerViewHeight).isActive = true
    widthAnchor.constraint(equalToConstant: Constants.dividerViewWidth).isActive = true
    backgroundColor = Colors.color(for: .supportSeparator)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
