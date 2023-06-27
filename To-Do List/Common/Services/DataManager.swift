//
//  DataManager.swift
//  To-Do List
//
//  Created by Danila Belyi on 23.06.2023.
//

import UIKit

final class DataManager {
  static let shared = DataManager()
  private init() {}

  let fileCache = FileCache()
  var tasks: [Task] = []

  func getData() -> Task {
    fileCache.loadFromJSON(from: "task") { _ in }
    tasks = fileCache.tasks
    return tasks.first ?? Task(text: "", createdAt: .now, importance: .important, isDone: false)
  }

  func delete(_ item: Task, completion: @escaping (Error?) -> Void) {
    _ = fileCache.delete(item.id)
    fileCache.saveToJSON(to: "task") { error in
      switch error {
      case nil:
        completion(nil)
      default:
        completion(error)
      }
    }
  }

  func add(_ item: Task, completion: @escaping (Error?) -> Void) {
    _ = fileCache.add(item)
    fileCache.saveToJSON(to: "task") { error in
      switch error {
      case nil:
        completion(nil)
      default:
        completion(error)
      }
    }
  }
}
