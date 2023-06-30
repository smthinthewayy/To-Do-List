//
//  Task.swift
//  To-Do List
//
//  Created by Danila Belyi on 11.06.2023.
//

import Foundation

// MARK: - Task

/// This is a struct named Task that holds information about a to-do item.
/// It has seven properties:
/// - id: A unique identifier for the to-do item. Optional and generates a new `UUID` if not provided.
/// - text: The text description of the to-do item
/// - createdAt: The date the to-do item was created
/// - deadline: An optional deadline for the to-do item. Default to `nil` if not provided.
/// - changedAt: An optional date the to-do item was last changed. Default to `nil` if not provided.
/// - importance: A value that represents the importance of the to-do item
/// - isDone: A Boolean value that indicates whether the to-do item is complete or not
struct Task {
  var id: String
  var text: String
  var createdAt: Date
  var deadline: Date?
  var changedAt: Date?
  var importance: Importance
  var isDone: Bool

  init(
    id: String = UUID().uuidString,
    text: String,
    createdAt: Date,
    deadline: Date? = nil,
    changedAt: Date? = nil,
    importance: Importance,
    isDone: Bool
  ) {
    self.id = id
    self.text = text
    self.createdAt = createdAt
    self.deadline = deadline
    self.changedAt = changedAt
    self.importance = importance
    self.isDone = isDone
  }
}

// MARK: - Importance

/// This is an enum named Importance that represents the importance of a to-do item.
/// It has three possible values: low, normal, and important.
/// The raw value of each case is a string.
enum Importance: String {
  case low
  case normal
  case important
}

extension Task {
  /// Converts a Task instance to a dictionary that can be serialized to JSON.
  /// The dictionary contains values for all non-nil Task properties, with the
  /// exception of .normal Importance. Dates are represented as Unix timestamps
  /// (seconds since January 1, 1970).
  var json: Any {
    var dict: [String: Any] = [:]

    dict[Keys.id.rawValue] = id
    dict[Keys.text.rawValue] = text
    dict[Keys.createdAt.rawValue] = Int(createdAt.timeIntervalSince1970)

    if let deadline = deadline {
      dict[Keys.deadline.rawValue] = Int(deadline.timeIntervalSince1970)
    }

    if let changedAt = changedAt {
      dict[Keys.changedAt.rawValue] = Int(changedAt.timeIntervalSince1970)
    }

    if importance != .normal {
      dict[Keys.importance.rawValue] = importance.rawValue
    }

    dict[Keys.isDone.rawValue] = isDone

    return dict
  }

  /// The parse function converts a JSON object (represented as Any) to a Task instance.
  /// The function returns nil if the JSON object doesn't contain all the required keys or if
  /// the values cannot be converted to the correct types. The Importance enum is parsed from
  /// a string representation. Dates are parsed from Unix timestamps.
  /// - Parameter json: JSON object
  /// - Returns: Task instance if the JSON object contains all the required keys and values,
  /// otherwise it returns nil.
  static func parse(json: Any) -> Task? {
    guard let json = json as? [String: Any],
          let id = json[Keys.id.rawValue] as? String,
          let text = json[Keys.text.rawValue] as? String,
          let isDone = (json[Keys.isDone.rawValue] as? Bool)
    else { return nil }

    let importance: Importance
    if let importanceRawValue = json[Keys.importance.rawValue] as? String {
      if importanceRawValue == Importance.low.rawValue || importanceRawValue == Importance.normal
        .rawValue || importanceRawValue == Importance.important.rawValue
      {
        importance = Importance(rawValue: importanceRawValue)!
      } else {
        return nil
      }
    } else {
      importance = Importance.normal
    }

    let createdAtTimestamp = json[Keys.createdAt.rawValue] as? Int
    let deadlineTimestamp = json[Keys.deadline.rawValue] as? Int
    let changedAtTimestamp = json[Keys.changedAt.rawValue] as? Int

    let createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtTimestamp!))
    let deadline: Date? = (deadlineTimestamp != nil) ? Date(timeIntervalSince1970: TimeInterval(deadlineTimestamp!)) : nil
    let changedAt: Date? = (changedAtTimestamp != nil) ? Date(timeIntervalSince1970: TimeInterval(changedAtTimestamp!)) : nil

    return Task(
      id: id,
      text: text,
      createdAt: createdAt,
      deadline: deadline,
      changedAt: changedAt,
      importance: importance,
      isDone: isDone
    )
  }

  /// This is a private enumeration named Keys that conforms to the RawRepresentable protocol with
  /// a raw value of type String. The enumeration contains cases for each key that is used in the
  /// dictionary representation of a Task.
  private enum Keys: String {
    case id
    case text
    case createdAt
    case deadline
    case changedAt
    case importance
    case isDone
  }
}

extension Task {
  /// This property is used to convert a `Task` instance to a string that represents the object in
  /// CSV format. The CSV format consists of a comma-separated list of values, with each row representing
  /// a single `Task`.
  var csv: String {
    var string = ""

    string += "\(id);\(text);\(Int(createdAt.timeIntervalSince1970));"

    if let deadline = deadline {
      string += "\(Int(deadline.timeIntervalSince1970));"
    } else {
      string += ";"
    }

    if let changedAt = changedAt {
      string += "\(Int(changedAt.timeIntervalSince1970));"
    } else {
      string += ";"
    }

    if importance != .normal {
      string += "\(importance.rawValue);"
    } else {
      string += ";"
    }

    string += "\(isDone)"

    return string
  }

  /// This method is used to parse a CSV string and return a `Task` instance. The `parse` method returns
  /// nil if the CSV string does not contain all the required information or if the values cannot be converted
  /// to the correct types. The `Importance` enum is parsed from a string representation.
  /// - Parameter csv: A string that represents a single Task object in CSV format.
  /// - Returns: Returns: `Task` instance if the CSV string contains all the required keys and values,
  /// otherwise it returns nil.
  static func parse(csv: String) -> Task? {
    let items = csv.components(separatedBy: ";")

    guard items.filter({ $0 != "" }).count >= 4, items.count <= 7 else { return nil }
    let id = String(items[0])
    let text = String(items[1])
    let isDone = Bool(items[6]) ?? false

    var importance = Importance.normal
    let importanceRawValue = items[5] == "" ? "normal" : String(items[5])
    if importanceRawValue == Importance.low.rawValue || importanceRawValue == Importance.normal.rawValue || importanceRawValue == Importance
      .important.rawValue
    {
      importance = Importance(rawValue: importanceRawValue)!
    } else {
      return nil
    }

    let createdAtTimestamp = Int(items[2])
    let deadlineTimestamp = items[3] == "" ? nil : Int(items[3])
    let changedAtTimestamp = items[4] == "" ? nil : Int(items[4])

    let createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtTimestamp!))
    let deadline: Date? = (deadlineTimestamp != nil) ? Date(timeIntervalSince1970: TimeInterval(deadlineTimestamp!)) : nil
    let changedAt: Date? = (changedAtTimestamp != nil) ? Date(timeIntervalSince1970: TimeInterval(changedAtTimestamp!)) : nil

    return Task(
      id: id,
      text: text,
      createdAt: createdAt,
      deadline: deadline,
      changedAt: changedAt,
      importance: importance,
      isDone: isDone
    )
  }
}
