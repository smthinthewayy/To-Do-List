//
//  TaskDescriptionTextView.swift
//  To-Do List
//
//  Created by Danila Belyi on 20.06.2023.
//

import UIKit

// MARK: - TaskTextViewDelegate

protocol TaskTextViewDelegate: AnyObject {
  func textViewDidChangeText(_ textView: UITextView)
  func fetchTaskDescription(_ textView: UITextView)
}

// MARK: - TaskTextView

class TaskTextView: UITextView {
  private enum Constants {
    static let textViewTextContainerTopPadding: CGFloat = 17
    static let textViewTextContainerLeftPadding: CGFloat = 16
    static let textViewTextContainerBottomPadding: CGFloat = 17
    static let textViewTextContainerRightPadding: CGFloat = 16
    static let cornerRadius: CGFloat = 16
  }

  weak var myDelegate: TaskTextViewDelegate?

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
}

// MARK: UITextViewDelegate

extension TaskTextView: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if !textView.text.isEmpty && textView.text == "Что надо сделать?" {
      textView.text = nil
      textView.textColor = Colors.color(for: .labelPrimary)
    }
  }

  func textViewDidChange(_ textView: UITextView) {
    myDelegate?.textViewDidChangeText(textView)
    myDelegate?.fetchTaskDescription(textView)
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "Что надо сделать?"
      textView.textColor = Colors.color(for: .labelTertiary)
    }
  }
}
