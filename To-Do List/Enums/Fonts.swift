//
//  Fonts.swift
//  To-Do List
//
//  Created by Danila Belyi on 20.06.2023.
//

import UIKit

// MARK: - Fonts

enum Fonts {
  case largeTitle
  case title
  case headline
  case body
  case mediumSubhead
  case subhead
  case footnote

  var font: UIFont? {
    switch self {
    case .largeTitle:
      return UIFont.systemFont(ofSize: 38, weight: .bold)
    case .title:
      return UIFont.systemFont(ofSize: 20, weight: .semibold)
    case .headline:
      return UIFont.systemFont(ofSize: 17, weight: .semibold)
    case .body:
      return UIFont.systemFont(ofSize: 17, weight: .regular)
    case .mediumSubhead:
      return UIFont.systemFont(ofSize: 15, weight: .medium)
    case .subhead:
      return UIFont.systemFont(ofSize: 15, weight: .regular)
    case .footnote:
      return UIFont.systemFont(ofSize: 13, weight: .semibold)
    }
  }

  static func font(for fontCase: Fonts) -> UIFont {
    return fontCase.font ?? UIFont()
  }
}
