//
//  TaskDetailsView.swift
//  To-Do List
//
//  Created by Danila Belyi on 18.06.2023.
//

import UIKit

// MARK: - TaskDetailsViewDelegate

protocol TaskDetailsViewDelegate: AnyObject {
  func switchTapped(_ sender: UISwitch)
  func segmentControlTapped(_ sender: UISegmentedControl)
  func deleteButtonTapped()
  func toggleSaveButton(_ textView: UITextView)
  func dateSelection(_ date: DateComponents?)
  func fetchTaskDescription(_ textView: UITextView)
}

// MARK: - TaskDetailsView

class TaskDetailsView: UIView {
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.alwaysBounceVertical = true
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

  weak var delegate: TaskDetailsViewDelegate?

  let parametersView = ParametersView()

  var task = Task(text: "", createdAt: .now, importance: .important, isDone: false)

  let taskDescriptionTextView = TaskTextView()

  var taskDescription: String = ""

  var deleteButton = DeleteButton()

  init() {
    super.init(frame: .zero)
    setupObservers()
    initViewIfNeeded()
    setupView()
    setupTapGesture()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func initViewIfNeeded() {
//    item = DataManager.shared.getData()
//
//    if !item.text.isEmpty {
//      taskDescriptionTextView.text = item.text
//      taskDescriptionTextView.textColor = Colors.color(for: .labelPrimary)
//
//      switch item.importance {
//      case .important:
//        parametersView.importancePicker.selectedSegmentIndex = 2
//      case .low:
//        parametersView.importancePicker.selectedSegmentIndex = 0
//      default:
//        parametersView.importancePicker.selectedSegmentIndex = 1
//      }
//
//      if let deadline = item.deadline {
//        parametersView.deadlineSwitch.isOn = true
//        parametersView.deadlineDateButton.setTitle(formatDate(for: deadline), for: .normal)
//        parametersView.deadlineDateButton.isHidden = false
//        deleteButton.isEnabled = true
//      }
//    }
  }
  
  func refreshView() {
    if !task.text.isEmpty {
      taskDescriptionTextView.text = task.text
      taskDescriptionTextView.textColor = Colors.color(for: .labelPrimary)

      switch task.importance {
      case .important:
        parametersView.importancePicker.selectedSegmentIndex = 2
      case .low:
        parametersView.importancePicker.selectedSegmentIndex = 0
      default:
        parametersView.importancePicker.selectedSegmentIndex = 1
      }

      if let deadline = task.deadline {
        parametersView.deadlineSwitch.isOn = true
        parametersView.deadlineDateButton.setTitle(formatDate(for: deadline), for: .normal)
        parametersView.deadlineDateButton.isHidden = false
        deleteButton.isEnabled = true
      }
    }
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
        constant: 16 + Constants.deleteButtonHeight + Constants.scrollViewContentLayoutGuideHeightPadding
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
      parametersView.heightAnchor.constraint(greaterThanOrEqualToConstant: 112.5),
      parametersView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
    ])
  }

  private func setupDeleteButton() {
    addSubview(deleteButton)
    NSLayoutConstraint.activate([
      deleteButton.topAnchor.constraint(equalTo: parametersView.bottomAnchor, constant: 16),
      deleteButton.leadingAnchor.constraint(equalTo: parametersView.leadingAnchor),
      deleteButton.heightAnchor.constraint(equalToConstant: 56),
      deleteButton.widthAnchor.constraint(equalToConstant: 343),
    ])
  }
}

// MARK: Keyboard Processing

extension TaskDetailsView {
  private func setupObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }

  @objc private func keyboardWillShow(notification: NSNotification) {
    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
      let keyboardHeight = keyboardFrame.height
      scrollView.contentInset.bottom = keyboardHeight
    }
  }

  @objc private func keyboardWillHide(_: NSNotification) {
    scrollView.contentInset.bottom = 0.0
  }

  private func setupTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    tapGesture.cancelsTouchesInView = false
    addGestureRecognizer(tapGesture)
  }

  @objc private func handleTap() {
    endEditing(true)
  }
}

// MARK: TaskTextViewDelegate

extension TaskDetailsView: TaskTextViewDelegate {
  func fetchTaskDescription(_ textView: UITextView) {
    delegate?.fetchTaskDescription(textView)
  }

  func textViewDidChangeText(_ textView: UITextView) {
    taskDescription = textView.text
    delegate?.fetchTaskDescription(textView)
    delegate?.toggleSaveButton(textView)
  }
}

// MARK: ParametersViewDelegate

extension TaskDetailsView: ParametersViewDelegate {
  func dateSelection(_ date: DateComponents?) {
    delegate?.dateSelection(date)
  }

  @objc func switchTapped(_ sender: UISwitch) {
    delegate?.switchTapped(sender)
  }

  @objc func segmentControlTapped(_ sender: UISegmentedControl) {
    delegate?.segmentControlTapped(sender)
  }
}

// MARK: DeleteButtonDelegate

extension TaskDetailsView: DeleteButtonDelegate {
  func deleteButtonTapped() {
    delegate?.deleteButtonTapped()
  }
}
