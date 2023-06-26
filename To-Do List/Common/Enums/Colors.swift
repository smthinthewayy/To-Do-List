//
//  Extensions.swift
//  To-Do List
//
//  Created by Danila Belyi on 17.06.2023.
//

import UIKit

// MARK: - Colors

enum Colors {
  case backPrimary
  case backSecondary
  case backElevated
  case backIOSPrimary
  case blue
  case gray
  case grayLight
  case green
  case red
  case white
  case labelDisable
  case labelPrimary
  case labelSecondary
  case labelTertiary
  case supportNavBarBlur
  case supportOverlay
  case supportSeparator

  // MARK: - Colors

  var color: UIColor? {
    return UIColor(named: name)
  }

  var name: String {
    switch self {
    case .backPrimary:
      return "BackPrimary"
    case .backSecondary:
      return "BackSecondary"
    case .backElevated:
      return "Elevated"
    case .backIOSPrimary:
      return "IOSPrimary"
    case .blue:
      return "Blue"
    case .gray:
      return "Gray"
    case .grayLight:
      return "GrayLight"
    case .green:
      return "Green"
    case .red:
      return "Red"
    case .white:
      return "White"
    case .labelDisable:
      return "Disable"
    case .labelPrimary:
      return "Primary"
    case .labelSecondary:
      return "Secondary"
    case .labelTertiary:
      return "Tertiary"
    case .supportNavBarBlur:
      return "NavBarBlur"
    case .supportOverlay:
      return "Overlay"
    case .supportSeparator:
      return "Separator"
    }
  }

  static func color(for colorCase: Colors) -> UIColor {
    return colorCase.color ?? .clear
  }
}
