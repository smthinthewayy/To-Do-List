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

  var image: UIImage? {
    return UIImage(named: name)
  }

  var name: String {
    switch self {
    case .lowImportance:
      return "LowImportance"
    case .highImportance:
      return "HighImportance"
    }
  }

  static func image(for imageCase: Images) -> UIImage {
    return imageCase.image ?? UIImage()
  }
}
