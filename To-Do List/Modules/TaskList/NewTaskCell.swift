//
//  NewTaskCell.swift
//  To-Do List
//
//  Created by Danila Belyi on 29.06.2023.
//

import UIKit

class NewTaskCell: UITableViewCell {
  private lazy var label: UILabel = {
    let label = UILabel()
    label.text = "Новое"
    label.textColor = Colors.color(for: .labelTertiary)
    label.font = Fonts.font(for: .body)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    backgroundColor = Colors.color(for: .backSecondary)
    setupLabel()
  }

  private func setupLabel() {
    contentView.addSubview(label)
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: contentView.topAnchor),
      label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 52),
      label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      label.heightAnchor.constraint(greaterThanOrEqualToConstant: 56)
    ])
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}
