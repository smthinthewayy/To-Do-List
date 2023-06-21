//
//  TaskDescriptionTextView.swift
//  To-Do List
//
//  Created by Danila Belyi on 20.06.2023.
//

import UIKit

// MARK: - TaskDescriptionTextViewDelegate

protocol TaskDescriptionTextViewDelegate: AnyObject {
  func textViewDidChangeText(_ textView: UITextView)
}

// MARK: - TaskDescriptionTextView

class TaskDescriptionTextView: UITextView {
  weak var myDelegate: TaskDescriptionTextViewDelegate?

  init() {
    super.init(frame: .zero, textContainer: nil)
    backgroundColor = Colors.color(for: .backSecondary)
    layer.cornerRadius = Constants.cornerRadius
    font = Fonts.font(for: .body)
    textColor = Colors.color(for: .labelTertiary)
    text = "Что надо сделать?"
    textContainerInset = UIEdgeInsets(
      top: Constants.textViewTextContainerTopPadding,
      left: Constants.textViewTextContainerLeftPadding,
      bottom: Constants.textViewTextContainerBottomPadding,
      right: Constants.textViewTextContainerRightPadding
    )
    isScrollEnabled = false
    delegate = self
    translatesAutoresizingMaskIntoConstraints = false
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private enum Constants {
    static let textViewTopPadding: CGFloat = 17
    static let textViewLeftPadding: CGFloat = 16
    static let textViewRightPadding: CGFloat = -16
    static let textViewHeight: CGFloat = 120
    static let textViewTextContainerTopPadding: CGFloat = 17
    static let textViewTextContainerLeftPadding: CGFloat = 16
    static let textViewTextContainerBottomPadding: CGFloat = 17
    static let textViewTextContainerRightPadding: CGFloat = 16

    static let cornerRadius: CGFloat = 16
  }
}

// MARK: UITextViewDelegate

extension TaskDescriptionTextView: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if !textView.text.isEmpty && textView.textColor == Colors.color(for: .labelTertiary) {
      textView.text = nil
      textView.textColor = Colors.color(for: .labelPrimary)
    }
  }

  func textViewDidChange(_ textView: UITextView) {
    myDelegate?.textViewDidChangeText(textView)
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "Что надо сделать?"
      textView.textColor = Colors.color(for: .labelTertiary)
    }
  }
}
