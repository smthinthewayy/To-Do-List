//
//  Helpers.swift
//  To-Do List
//
//  Created by Danila Belyi on 24.06.2023.
//

import UIKit

public func formatDate(for date: Date?) -> String {
  guard let date = date else { return "invalid date" }
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "d MMMM yyyy"
  let dateString = dateFormatter.string(from: date)
  return dateString
}
