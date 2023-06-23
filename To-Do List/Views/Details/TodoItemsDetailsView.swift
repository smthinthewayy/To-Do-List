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
  func dateSelection(_ date: DateComponents?)
  func fetchTaskDescription(_ textView: UITextView)
}

// MARK: - TodoItemDetailsView

class TodoItemDetailsView: UIView {
  weak var delegate: TodoItemDetailsViewDelegate?

  var item: TodoItem = DataManager.shared.getData()

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

  let taskDescriptionTextView = TaskDescriptionTextView()
  var taskDescription: String = ""

  let parametersView = ParametersView()

  var deleteButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = Colors.color(for: .backSecondary)
    button.setTitle("Удалить", for: .normal)
    button.setTitleColor(Colors.color(for: .red), for: .normal)
    button.isEnabled = false
    button.setTitleColor(Colors.color(for: .labelTertiary), for: .disabled)
    button.layer.cornerRadius = Constants.cornerRadius
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  init() {
    super.init(frame: .zero)

    item = DataManager.shared.getData()

    if !item.text.isEmpty {
      taskDescriptionTextView.text = item.text
      taskDescriptionTextView.textColor = Colors.color(for: .labelPrimary)

      switch item.importance {
      case .important:
        parametersView.importancePicker.selectedSegmentIndex = 2
      case .low:
        parametersView.importancePicker.selectedSegmentIndex = 0
      default:
        parametersView.importancePicker.selectedSegmentIndex = 1
      }

      if item.deadline != nil {
        parametersView.deadlineSwitch.isOn = (item.deadline != nil)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        let dateString = dateFormatter.string(from: item.deadline!)

        parametersView.deadlineDateButton.setTitle(dateString, for: .normal)
        parametersView.deadlineDateButton.isHidden = false

        deleteButton.isEnabled = true
      }
    }

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
      //      parametersView.topAnchor.constraint(equalTo: taskDescriptionTextView.bottomAnchor, constant: 16)
      parametersView.heightAnchor.constraint(greaterThanOrEqualToConstant: 112.5),
      parametersView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
    ])
  }

  private func setupDeleteButton() {
    addSubview(deleteButton)
    deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    NSLayoutConstraint.activate([
      deleteButton.topAnchor.constraint(equalTo: parametersView.bottomAnchor, constant: 16),
      deleteButton.leadingAnchor.constraint(equalTo: parametersView.leadingAnchor),
      deleteButton.heightAnchor.constraint(equalToConstant: 56),
      deleteButton.widthAnchor.constraint(equalToConstant: 343),
    ])
  }

  private func setupTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    tapGesture.cancelsTouchesInView = false
    addGestureRecognizer(tapGesture)
  }

  @objc private func handleTap() {
    endEditing(true)
  }

  @objc func deleteButtonTapped() {
    delegate?.deleteButtonTapped()
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

extension TodoItemDetailsView: ParametersViewDelegate {
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
