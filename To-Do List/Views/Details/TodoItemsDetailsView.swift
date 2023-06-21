//
//  TodoItemsDetailsView.swift
//  To-Do List
//
//  Created by Danila Belyi on 18.06.2023.
//

import UIKit

// MARK: - TodoItemDetailsViewDelegate

protocol TodoItemDetailsViewDelegate: AnyObject {
  func switchTapped(_ sender: UISwitch)
  func segmentControlTapped(_ sender: UISegmentedControl)
  func deleteButtonTapped()
  func toggleSaveButton(_ textView: UITextView)
}

// MARK: - TodoItemDetailsView

class TodoItemDetailsView: UIView, UITextViewDelegate {
  weak var delegate: TodoItemDetailsViewDelegate?

  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    return scrollView
  }()

  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = Constants.stackViewSpacing
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()

  private let taskDescriptionTextView = TaskDescriptionTextView()

  private let parametersView = ParametersView()

  private let deleteButton = DeleteButton()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    setupTapGesture()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    backgroundColor = Colors.color(for: .backPrimary)
    taskDescriptionTextView.myDelegate = self
    parametersView.delegate = self
    deleteButton.delegate = self
    translatesAutoresizingMaskIntoConstraints = false

    setupScrollView()
    setupStackView()
    setupTaskDescriptionTextView()
    setupParametersView()
    setupDeleteButton()
  }

  private func setupScrollView() {
    addSubview(scrollView)
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.scrollViewLeadingPadding),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.scrollViewTrailingPadding),
      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.scrollViewBottomPadding),
    ])
  }

  private func setupStackView() {
    scrollView.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: Constants.stackViewTopPading),
      stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: stackView.widthAnchor),
      scrollView.contentLayoutGuide.heightAnchor.constraint(
        equalTo: stackView.heightAnchor,
        constant: Constants.scrollViewContentLayoutGuideHeightPadding
      ),
    ])
  }

  private func setupTaskDescriptionTextView() {
    stackView.addArrangedSubview(taskDescriptionTextView)
    NSLayoutConstraint.activate([
      taskDescriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textViewHeight),
    ])
  }

  private func setupParametersView() {
    stackView.addArrangedSubview(parametersView)
    NSLayoutConstraint.activate([
      parametersView.heightAnchor.constraint(equalToConstant: Constants.parametersViewHeight),
    ])
  }

  private func setupDeleteButton() {
    stackView.addArrangedSubview(deleteButton)
    NSLayoutConstraint.activate([
      deleteButton.heightAnchor.constraint(equalToConstant: Constants.deleteButtonHeight),
    ])
  }

  private func setupTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    addGestureRecognizer(tapGesture)
  }

  @objc private func handleTap() {
    endEditing(true)
  }

  private enum Constants {
    static let scrollViewLeadingPadding: CGFloat = 16
    static let scrollViewTrailingPadding: CGFloat = -16
    static let scrollViewBottomPadding: CGFloat = 16
    static let scrollViewContentLayoutGuideHeightPadding = 66.5

    static let stackViewTopPading: CGFloat = 16
    static let stackViewHeight: CGFloat = 352.5
    static let stackViewSpacing: CGFloat = 16

    static let textViewTopPadding: CGFloat = 17
    static let textViewLeftPadding: CGFloat = 16
    static let textViewRightPadding: CGFloat = -16
    static let textViewHeight: CGFloat = 120
    static let textViewTextContainerTopPadding: CGFloat = 17
    static let textViewTextContainerLeftPadding: CGFloat = 16
    static let textViewTextContainerBottomPadding: CGFloat = 17
    static let textViewTextContainerRightPadding: CGFloat = 16

    static let cornerRadius: CGFloat = 16

    static let parametersViewTopPadding: CGFloat = 16
    static let parametersViewLeftPadding: CGFloat = 16
    static let parametersViewRightPadding: CGFloat = -16
    static let parametersViewHeight: CGFloat = 112.5

    static let deleteButtonTopPadding: CGFloat = 16
    static let deleteButtonLeadingPadding: CGFloat = 16
    static let deleteButtonTrailingPadding: CGFloat = -16
    static let deleteButtonHeight: CGFloat = 56
  }
}

// MARK: TaskDescriptionTextViewDelegate

extension TodoItemDetailsView: TaskDescriptionTextViewDelegate {
  func textViewDidChangeText(_ textView: UITextView) {
    delegate?.toggleSaveButton(textView)
  }
}

// MARK: ParametersViewDelegate

extension TodoItemDetailsView: ParametersViewDelegate {
  @objc func switchTapped(_ sender: UISwitch) {
    delegate?.switchTapped(sender)
  }

  @objc func segmentControlTapped(_ sender: UISegmentedControl) {
    delegate?.segmentControlTapped(sender)
  }
}

// MARK: DeleteButtonDelegate

extension TodoItemDetailsView: DeleteButtonDelegate {
  func deleteButtonTapped() {
    delegate?.deleteButtonTapped()
  }
}
