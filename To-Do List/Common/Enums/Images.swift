//
//  Images.swift
//  To-Do List
//
//  Created by Danila Belyi on 18.06.2023.
//

import UIKit

// MARK: - Images

enum Images {
  case lowImportance
  case highImportance
  case addButton
  case calendar
  case chevron
  case RBhighPriority
  case RBoff
  case RBon
  case circleCheckmark
  case circleInfo
  case trash

  var image: UIImage? {
    return UIImage(named: name)
  }

  var name: String {
    switch self {
    case .lowImportance:
      return "LowImportance"
    case .highImportance:
      return "HighImportance"
    case .addButton:
      return "addButton"
    case .calendar:
      return "calendar"
    case .chevron:
      return "chevron"
    case .RBhighPriority:
      return "RBhighPriority"
    case .RBoff:
      return "RBoff"
    case .RBon:
      return "RBon"
    case .circleCheckmark:
      return "circleCheckmark"
    case .circleInfo:
      return "circleInfo"
    case .trash:
      return "trash"
    }
  }

  static func image(for imageCase: Images) -> UIImage {
    return imageCase.image ?? UIImage()
  }
}
