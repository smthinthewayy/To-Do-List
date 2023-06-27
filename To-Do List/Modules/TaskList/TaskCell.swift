//
//  TaskCell.swift
//  To-Do List
//
//  Created by Danila Belyi on 26.06.2023.
//

import UIKit

class TaskCell: UITableViewCell {
  let taskStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.distribution = .equalSpacing
    stackView.spacing = 0
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()

  let titleStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.spacing = 2
    stackView.distribution = .equalSpacing
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()

  let deadlineStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.spacing = 2
    stackView.distribution = .equalSpacing
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()

  let calendarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = Images.image(for: .calendar)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()

  let deadlineLabel: UILabel = {
    let label = UILabel()
    label.font = Fonts.font(for: .subhead)
    label.textColor = Colors.color(for: .labelTertiary)
    return label
  }()

  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Fonts.font(for: .body)
    label.textColor = Colors.color(for: .labelPrimary)
    label.numberOfLines = 3
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let chevron: UIImageView = {
    let imageView = UIImageView()
    imageView.image = Images.image(for: .chevron)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()

  private let status: UIImageView = {
    let imageView = UIImageView()
    imageView.image = Images.image(for: .RBoff)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()

  private lazy var statusButton: UIButton = {
    let button = UIButton()
    button.setImage(Images.image(for: .RBoff), for: .normal)
    button.addTarget(self, action: #selector(statusButtonTapped), for: .touchUpInside)
    button.frame.size = CGSize(width: 24, height: 24)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let statusIcon: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()

  private var dividerView: UIView = {
    let view = UIView()
    view.heightAnchor.constraint(equalToConstant: 1).isActive = true
    view.backgroundColor = Colors.color(for: .supportSeparator)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    separatorInset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 0)

    backgroundColor = Colors.color(for: .backSecondary)
    contentView.addSubview(chevron)
    NSLayoutConstraint.activate([
      chevron.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
    ])

    contentView.addSubview(statusButton)
    NSLayoutConstraint.activate([
      statusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      statusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
    ])

//    contentView.addSubview(dividerView)
//    NSLayoutConstraint.activate([
//      dividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 52),
//      dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
//      dividerView.bottomAnchor.constraint(equalTo: bottomAnchor),
//    ])

    contentView.addSubview(taskStackView)
    NSLayoutConstraint.activate([
      taskStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      taskStackView.leadingAnchor.constraint(equalTo: statusButton.trailingAnchor, constant: 12),
      taskStackView.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -16),
      taskStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      taskStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
    ])

    taskStackView.addArrangedSubview(titleStackView)
  }

  func configure(with task: Task) {
    titleLabel.text = task.text
    if task.importance == .important {
      statusButton.setImage(Images.image(for: .RBhighPriority), for: .normal)
      statusIcon.image = Images.image(for: .highImportance)
      titleStackView.addArrangedSubview(statusIcon)
      titleStackView.addArrangedSubview(titleLabel)
    } else if task.importance == .low {
      statusIcon.image = Images.image(for: .lowImportance)
      titleStackView.addArrangedSubview(statusIcon)
      titleStackView.addArrangedSubview(titleLabel)
    } else {
      titleStackView.addArrangedSubview(titleLabel)
    }

    if task.isDone {
//      status.image = Images.image(for: .RBon)
      statusButton.setImage(Images.image(for: .RBon), for: .normal)
      let attributeString = NSMutableAttributedString(string: task.text)
      attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
      titleLabel.textColor = Colors.color(for: .labelTertiary)
      titleLabel.attributedText = attributeString
      titleStackView.addArrangedSubview(titleLabel)
    }

    if let deadline = task.deadline {
      taskStackView.addArrangedSubview(deadlineStackView)
      deadlineStackView.addArrangedSubview(calendarImageView)
      deadlineLabel.text = formatDateWithoutYear(for: deadline)
      deadlineStackView.addArrangedSubview(deadlineLabel)
    }
  }

  @objc private func statusButtonTapped(_ sender: UIButton) {
    let attributeString = NSMutableAttributedString(string: titleLabel.text!)
    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
    if sender.currentImage == Images.image(for: .RBoff) || sender.currentImage == Images.image(for: .RBhighPriority) {
      sender.setImage(Images.image(for: .RBon), for: .normal)
      titleLabel.textColor = Colors.color(for: .labelTertiary)
      titleLabel.attributedText = attributeString
    } else {
      sender.setImage(Images.image(for: .RBoff), for: .normal)
      titleLabel.textColor = Colors.color(for: .labelPrimary)
      attributeString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, attributeString.length))
      titleLabel.attributedText = attributeString
    }
  }

  required init?(coder _: NSCoder) {
    nil
  }

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}
