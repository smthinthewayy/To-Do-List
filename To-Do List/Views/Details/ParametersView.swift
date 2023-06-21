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
}

// MARK: - ParametersView

class ParametersView: UIView {
  weak var delegate: ParametersViewDelegate?

  private let dividerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.heightAnchor.constraint(equalToConstant: Constants.dividerViewHeight).isActive = true
    view.widthAnchor.constraint(equalToConstant: Constants.dividerViewWidth).isActive = true
    view.backgroundColor = Colors.color(for: .supportSeparator)
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

  private let deadlineLabel: UILabel = {
    let label = UILabel()
    label.text = "Сделать до"
    label.font = Fonts.font(for: .body)
    label.textColor = Colors.color(for: .labelPrimary)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var importancePicker: UISegmentedControl = {
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

  private lazy var deadlineSwitch: UISwitch = {
    let deadlineSwitch = UISwitch()
    deadlineSwitch.addTarget(self, action: #selector(switchTapped), for: .valueChanged)
    deadlineSwitch.translatesAutoresizingMaskIntoConstraints = false
    return deadlineSwitch
  }()

  init() {
    super.init(frame: .zero)

    backgroundColor = Colors.color(for: .backSecondary)
    layer.cornerRadius = Constants.cornerRadius
    translatesAutoresizingMaskIntoConstraints = false

    setupDividerView()
    setupImportanceLabel()
    setupDeadlineLabel()
    setupImportancePicker()
    setupDeadlineSwitch()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupDividerView() {
    addSubview(dividerView)
    NSLayoutConstraint.activate([
      dividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.dividerViewLeftPadding),
      dividerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.dividerViewRightPadding),
      dividerView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.dividerViewTopPadding),
    ])
  }

  private func setupImportanceLabel() {
    addSubview(importanceLabel)
    NSLayoutConstraint.activate([
      importanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.importanceLabelLeftPadding),
      importanceLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.importanceLabelTopPadding),
    ])
  }

  private func setupDeadlineLabel() {
    addSubview(deadlineLabel)
    NSLayoutConstraint.activate([
      deadlineLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.deadlineLabelLeftPadding),
      deadlineLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.deadlinLabelBottomPadding),
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

  private func setupDeadlineSwitch() {
    addSubview(deadlineSwitch)
    NSLayoutConstraint.activate([
      deadlineSwitch.widthAnchor.constraint(equalToConstant: Constants.deadlineSwitchWidth),
      deadlineSwitch.heightAnchor.constraint(equalToConstant: Constants.deadlineSwitchHeight),
      deadlineSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.deadlineSwitchRightPadding),
      deadlineSwitch.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.deadlineSwitchBottomPadding),
    ])
  }

  @objc func switchTapped(_ sender: UISwitch) {
    delegate?.switchTapped(sender)
  }

  @objc func segmentControlTapped(_ sender: UISegmentedControl) {
    delegate?.segmentControlTapped(sender)
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
