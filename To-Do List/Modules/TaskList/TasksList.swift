//
//  TasksList.swift
//  To-Do List
//
//  Created by Danila Belyi on 26.06.2023.
//

import UIKit

class TasksList: UITableView {
  private enum Constants {
    static let estimatedRowHeight: CGFloat = 56
    static let cornerRadius: CGFloat = 16
    static let cellIdentifier: String = "TasksListItemCell"
  }

  init() {
    super.init(frame: .zero, style: .insetGrouped)
    
    backgroundColor = .clear
    register(
      TaskCell.self,
      forCellReuseIdentifier: Constants.cellIdentifier
    )
    rowHeight = UITableView.automaticDimension
    estimatedRowHeight = Constants.estimatedRowHeight
//    separatorStyle = .none
    showsVerticalScrollIndicator = false
    translatesAutoresizingMaskIntoConstraints = false
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
