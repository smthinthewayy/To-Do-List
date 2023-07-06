//
//  FileCache.swift
//  To-Do List
//
//  Created by Danila Belyi on 11.06.2023.
//

import Foundation

// MARK: - FileCache

class FileCache {
  var tasks: [Task] = []

  func add(_ newTask: Task) -> Task? {
    if let index = tasks.firstIndex(where: { $0.id == newTask.id }) {
      let oldtask = tasks[index]
      tasks[index] = newTask
      return oldtask
    } else {
      tasks.append(newTask)
      return nil
    }
  }

  func delete(_ id: String) -> Task? {
    if let index = tasks.firstIndex(where: { $0.id == id }) {
      let task = tasks[index]
      tasks.remove(at: index)
      return task
    } else {
      return nil
    }
  }

  func saveToJSON(to file: String, completion: @escaping (Error?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
          throw FileCacheErrors.directoryNotFound
        }

        let path = directory.appending(path: "\(file).json")
        let serializedtasks = self.tasks.map { $0.json }
        let data = try JSONSerialization.data(withJSONObject: serializedtasks)
        try data.write(to: path)

        DispatchQueue.main.async {
          completion(nil)
        }
      } catch {
        DispatchQueue.main.async {
          completion(error)
        }
      }
    }
  }

  func saveToCSV(to file: String, completion: @escaping (Error?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
          throw FileCacheErrors.directoryNotFound
        }

        let path = directory.appending(path: "\(file).csv")
        var serializedtasks = self.tasks.map { $0.csv }

        serializedtasks.insert("id;text;createdAt;deadline;changedAt;importance;isDone", at: 0)

        let data = serializedtasks.joined(separator: "\n").data(using: .utf8)!
        try data.write(to: path, options: .atomic)

        DispatchQueue.main.async {
          completion(nil)
        }
      } catch {
        DispatchQueue.main.async {
          completion(error)
        }
      }
    }
  }

  func loadFromJSON(from file: String, completion: @escaping (Error?) -> Void) {
    do {
      guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        throw FileCacheErrors.directoryNotFound
      }

      let path = directory.appending(path: "\(file).json")
      let data = try Data(contentsOf: path)
      let json = try JSONSerialization.jsonObject(with: data)

      guard let json = json as? [Any] else {
        throw FileCacheErrors.invalidData
      }

      let deserializedtasks = json.compactMap { Task.parse(json: $0) }
        .sorted { $0.createdAt.timeIntervalSince1970 > $1.createdAt.timeIntervalSince1970 }
      tasks = deserializedtasks

      DispatchQueue.main.async {
        completion(nil)
      }
    } catch {
      DispatchQueue.main.async {
        completion(error)
      }
    }
  }

  func loadFromCSV(from file: String, completion: @escaping (Error?) -> Void) {
    do {
      guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        throw FileCacheErrors.directoryNotFound
      }

      let path = directory.appending(path: "\(file).csv")
      let data = try String(contentsOf: path, encoding: .utf8)
      let rows = data.split(separator: "\n")

      var deserializedtasks = [Task]()

      for row in 1 ..< rows.count {
        deserializedtasks.append(Task.parse(csv: String(rows[row]))!)
      }

      tasks = deserializedtasks

      DispatchQueue.main.async {
        completion(nil)
      }
    } catch {
      DispatchQueue.main.async {
        completion(error)
      }
    }
  }
}

// MARK: - FileCacheErrors

enum FileCacheErrors: Error {
  case directoryNotFound
  case invalidData
}
