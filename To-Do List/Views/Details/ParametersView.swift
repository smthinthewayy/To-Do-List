//
//  ParametersView.swift
//  To-Do List
//
//  Created by Danila Belyi on 20.06.2023.
//

import UIKit

// MARK: - ParametersViewDelegate

protocol ParametersViewDelegate: AnyObject {
  func switchTapped(_ sender: UISwitch)
  func segmentControlTapped(_ sender: UISegmentedControl)
  func dateSelection(_ date: DateComponents?)
}

// MARK: - ParametersView

class ParametersView: UIStackView {
  weak var delegate: ParametersViewDelegate?

  private let dividerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.heightAnchor.constraint(equalToConstant: Constants.dividerViewHeight).isActive = true
    view.widthAnchor.constraint(equalToConstant: Constants.dividerViewWidth).isActive = true
    view.backgroundColor = Colors.color(for: .supportSeparator)
    return view
  }()

  private let hiddenDividerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.heightAnchor.constraint(equalToConstant: 0.75).isActive = true
    view.widthAnchor.constraint(equalToConstant: Constants.dividerViewWidth).isActive = true
    view.isHidden = false
    view.backgroundColor = Colors.color(for: .backSecondary)
    return view
  }()

  private let importanceLabel: UILabel = {
    let label = UILabel()
    label.text = "Важность"
    label.font = Fonts.font(for: .body)
    label.textColor = Colors.color(for: .labelPrimary)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let deadlineStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 0
    stackView.alignment = .leading
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()

  private let doneByLabel: UILabel = {
    let label = UILabel()
    label.text = "Сделать до"
    label.font = Fonts.font(for: .body)
    label.textColor = Colors.color(for: .labelPrimary)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var deadlineDateButton: UIButton = {
    let button = UIButton()
    button.setTitle("2 июня 2021", for: .normal)
    button.titleLabel?.font = Fonts.font(for: .footnote)
    button.setTitleColor(Colors.color(for: .blue), for: .normal)
    button.addTarget(self, action: #selector(deadlineDateTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.isHidden = true
    return button
  }()

  lazy var importancePicker: UISegmentedControl = {
    let segmentedControl = UISegmentedControl(items: [Images.image(for: .lowImportance).withRenderingMode(.alwaysOriginal), "нет",
                                                      Images.image(for: .highImportance).withRenderingMode(.alwaysOriginal)])
    segmentedControl.selectedSegmentIndex = 2
    segmentedControl.backgroundColor = Colors.color(for: .supportOverlay)
    segmentedControl.selectedSegmentTintColor = Colors.color(for: .backElevated)
    segmentedControl.addTarget(self, action: #selector(segmentControlTapped), for: .valueChanged)
    segmentedControl.setTitleTextAttributes([.foregroundColor: Colors.color(for: .labelPrimary),
                                             .font: Fonts.font(for: .mediumSubhead)], for: .normal)
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    return segmentedControl
  }()

  lazy var deadlineSwitch: UISwitch = {
    let deadlineSwitch = UISwitch()
    deadlineSwitch.addTarget(self, action: #selector(switchTapped), for: .valueChanged)
    deadlineSwitch.translatesAutoresizingMaskIntoConstraints = false
    return deadlineSwitch
  }()

  private lazy var calendarView: UICalendarView = {
    let calendarView = UICalendarView()
    calendarView.calendar = .current
    calendarView.locale = .current
    calendarView.availableDateRange = DateInterval(start: .now, end: .distantFuture)
    calendarView.isHidden = true
    calendarView.translatesAutoresizingMaskIntoConstraints = false
    return calendarView
  }()

  init() {
    super.init(frame: .zero)

    axis = .vertical
    layer.cornerRadius = 16
    backgroundColor = Colors.color(for: .backSecondary)
    spacing = 10
    translatesAutoresizingMaskIntoConstraints = false

    setupImportanceLabel()
    setupImportancePicker()
    setupDividerView()
    setupDeadlineStackView()
    setupDeadlineSwitch()
    setupHiddenDividerView()
    setupCalendarView()
  }

  @available(*, unavailable)
  required init(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupImportanceLabel() {
    addArrangedSubview(importanceLabel)
    NSLayoutConstraint.activate([
      importanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.importanceLabelLeftPadding),
      importanceLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.importanceLabelTopPadding),
    ])
  }

  private func setupImportancePicker() {
    addSubview(importancePicker)
    NSLayoutConstraint.activate([
      importancePicker.widthAnchor.constraint(equalToConstant: Constants.importancePickerWidth),
      importancePicker.heightAnchor.constraint(equalToConstant: Constants.importancePickerHeight),
      importancePicker.topAnchor.constraint(equalTo: topAnchor, constant: Constants.importancePickerTopPadding),
      importancePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.importancePickerRightPadding),
    ])
  }

  private func setupDividerView() {
    addArrangedSubview(dividerView)
    NSLayoutConstraint.activate([
      dividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.dividerViewLeftPadding),
      dividerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.dividerViewRightPadding),
      dividerView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.dividerViewTopPadding),
    ])
  }

  private func setupDeadlineStackView() {
    addArrangedSubview(deadlineStackView)
    NSLayoutConstraint.activate([
      deadlineStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      deadlineStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -80),
      deadlineStackView.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 8),
      deadlineStackView.heightAnchor.constraint(equalToConstant: 40),
    ])

    setupDoneByLabel()
    setupDeadlineDateLabel()
  }

  private func setupDoneByLabel() {
    deadlineStackView.addArrangedSubview(doneByLabel)
  }

  private func setupDeadlineDateLabel() {
    deadlineStackView.addArrangedSubview(deadlineDateButton)
  }

  private func setupDeadlineSwitch() {
    addSubview(deadlineSwitch)
    NSLayoutConstraint.activate([
      deadlineSwitch.widthAnchor.constraint(equalToConstant: Constants.deadlineSwitchWidth),
      deadlineSwitch.heightAnchor.constraint(equalToConstant: Constants.deadlineSwitchHeight),
      deadlineSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
      deadlineSwitch.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 12.5),
    ])
  }

  private func setupHiddenDividerView() {
    addArrangedSubview(hiddenDividerView)
    NSLayoutConstraint.activate([
      hiddenDividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.dividerViewLeftPadding),
      hiddenDividerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.dividerViewRightPadding),
      hiddenDividerView.topAnchor.constraint(equalTo: deadlineSwitch.bottomAnchor, constant: 8),
    ])
  }

  private func setupCalendarView() {
    addArrangedSubview(calendarView)
    let selection = UICalendarSelectionSingleDate(delegate: self)
    calendarView.selectionBehavior = selection
    NSLayoutConstraint.activate([
      calendarView.topAnchor.constraint(equalTo: hiddenDividerView.bottomAnchor, constant: 8),
      calendarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      calendarView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
      calendarView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
    ])
  }

  @objc func switchTapped(_ sender: UISwitch) {
    UIView.animate(withDuration: 0.25) {
      if sender.isOn {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        let dateString = dateFormatter.string(from: .now + 60 * 60 * 24)
        self.deadlineDateButton.setTitle(dateString, for: .normal)
        self.deadlineDateButton.isHidden = false
      } else {
        self.deadlineDateButton.isHidden = true
        self.hiddenDividerView.backgroundColor = Colors.color(for: .backSecondary)
        self.calendarView.isHidden = true
      }
    }

    delegate?.switchTapped(sender)
  }

  @objc func segmentControlTapped(_ sender: UISegmentedControl) {
    delegate?.segmentControlTapped(sender)
  }

  @objc func deadlineDateTapped() {
    UIView.animate(withDuration: 0.25) {
      self.calendarView.isHidden = false
      self.hiddenDividerView.isHidden = false
      self.hiddenDividerView.backgroundColor = Colors.color(for: .supportSeparator)
    }
  }

  private enum Constants {
    static let cornerRadius: CGFloat = 16

    static let dividerViewTopPadding: CGFloat = 56
    static let dividerViewLeftPadding: CGFloat = 16
    static let dividerViewRightPadding: CGFloat = -16
    static let dividerViewHeight: CGFloat = 0.5
    static let dividerViewWidth: CGFloat = 311

    static let importanceLabelLeftPadding: CGFloat = 16
    static let importanceLabelTopPadding: CGFloat = 17

    static let importancePickerWidth: CGFloat = 150
    static let importancePickerHeight: CGFloat = 36
    static let importancePickerTopPadding: CGFloat = 10
    static let importancePickerRightPadding: CGFloat = -12

    static let deadlineSwitchWidth: CGFloat = 51
    static let deadlineSwitchHeight: CGFloat = 31
    static let deadlineSwitchRightPadding: CGFloat = -12
    static let deadlineSwitchBottomPadding: CGFloat = -12.5

    static let deadlineLabelLeftPadding: CGFloat = 16
    static let deadlinLabelBottomPadding: CGFloat = -17
  }
}

// MARK: UICalendarSelectionSingleDateDelegate

extension ParametersView: UICalendarSelectionSingleDateDelegate {
  func dateSelection(_: UICalendarSelectionSingleDate, didSelectDate date: DateComponents?) {
    guard let date = date else {
      return
    }

    delegate?.dateSelection(date)

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d MMMM yyyy"
    let dateString = dateFormatter.string(from: date.date!)

    deadlineDateButton.setTitle(dateString, for: .normal)

    UIView.animate(withDuration: 0.25) {
      self.hiddenDividerView.backgroundColor = Colors.color(for: .backSecondary)
      self.calendarView.isHidden = true
    }
  }
}
