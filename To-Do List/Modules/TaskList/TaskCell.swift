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
    stackView.spacing = 0
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()

  let titleStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 2
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
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

  private var dividerView: UIView = {
    let view = UIView()
    view.heightAnchor.constraint(equalToConstant: 1).isActive = true
    view.backgroundColor = Colors.color(for: .supportSeparator)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    backgroundColor = Colors.color(for: .backSecondary)

    contentView.addSubview(chevron)
    NSLayoutConstraint.activate([
      chevron.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
    ])

    contentView.addSubview(status)
    NSLayoutConstraint.activate([
      status.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      status.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
    ])

    contentView.addSubview(dividerView)
    NSLayoutConstraint.activate([
      dividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 52),
      dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
      dividerView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

    contentView.addSubview(taskStackView)
    NSLayoutConstraint.activate([
      taskStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
      taskStackView.leadingAnchor.constraint(equalTo: status.trailingAnchor, constant: 12),
      taskStackView.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -16),
      taskStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      taskStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
    ])
    
    taskStackView.addArrangedSubview(titleLabel)
    NSLayoutConstraint.activate([
//      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
//      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 52),
//      titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -39),
//      titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
    ])
  }

  func configure(with task: Task) {
    titleLabel.text = task.text
    if task.importance == .important {
      status.image = Images.image(for: .RBhighPriority)

    } else if task.isDone {
      status.image = Images.image(for: .RBon)
      let attributeString = NSMutableAttributedString(string: task.text)
      attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
      titleLabel.textColor = Colors.color(for: .labelTertiary)
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
