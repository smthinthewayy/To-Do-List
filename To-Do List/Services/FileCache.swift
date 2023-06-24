//
//  FileCache.swift
//  To-Do List
//
//  Created by Danila Belyi on 11.06.2023.
//

import Foundation

// MARK: - FileCache

class FileCache {
  /// Is a private property that stores the `Task` objects in the cache. It is implemented as a Dictionary where
  /// the key is the ID of the `Task` and the value is the Task itself. It is marked as `private(set)` which
  /// means that it can only be modified within the `FileCache` class, but can be accessed from outside the class.
  private(set) var items: [String: Task] = [:]

  /// This method allows you to add a new `Task` object to the cache.
  /// - Parameter newItem: A Task object which is the item to be added to the cache.
  /// - Returns: A Task object which is the item that was previously associated with the same ID as the new item. If there was no previous item, it returns nil.
  func add(_ newItem: Task) -> Task? {
    let oldItem = items[newItem.id]
    items[newItem.id] = newItem
    return oldItem
  }

  /// This method allows you to delete a `Task` object from the cache using its ID.
  /// - Parameter id: A String which is the ID of the Task that needs to be deleted from the cache.
  /// - Returns: A Task object which is the item that was deleted from the cache. If there was no item with the given ID, it returns nil.
  func delete(_ id: String) -> Task? {
    let item = items[id]
    items[id] = nil
    return item
  }

  /// This method allows the user to save the `Task` objects stored in the cache to a file on the device.
  /// The method uses JSONSerialization to serialize the `Task` objects in the cache into a JSON array and
  /// writes it to a file in the document directory of the app. The method executes asynchronously on a background
  /// thread to avoid blocking the main thread.
  /// - Parameters:
  ///   - file: A String which is the name of the file to save the `Task` objects.
  ///   - completion: A closure that takes in an optional `Error` object as its parameter. The closure is executed
  ///   when the save operation is completed. If the save operation is successful, the closure is called with a nil
  ///   error parameter. If there is an error during the save operation, the closure is called with an Error object
  ///   that describes the error.
  func saveToJSON(to file: String, completion: @escaping (Error?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
          throw FileCacheErrors.directoryNotFound
        }

        let path = directory.appending(path: "\(file).json")
        let serializedItems = self.items.map { _, item in item.json }
        let data = try JSONSerialization.data(withJSONObject: serializedItems)
        try data.write(to: path)
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

  /// This method allows the user to save the `Task` objects stored in the cache to a CSV file on the device.
  /// The method creates a CSV file and writes the `Task` objects in the cache into it. The method executes
  /// asynchronously on a background thread to avoid blocking the main thread.
  /// - Parameters:
  ///   - file: A String which is the name of the file to save the `Task` objects.
  ///   - completion: A closure that takes in an optional `Error` object as its parameter. The closure is executed
  ///   when the save operation is completed. If the save operation is successful, the closure is called with a nil
  ///   error parameter. If there is an error during the save operation, the closure is called with an Error object
  ///   that describes the error.
  func saveToCSV(to file: String, completion: @escaping (Error?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
          throw FileCacheErrors.directoryNotFound
        }

        let path = directory.appending(path: "\(file).csv")
        var serializedItems = self.items.map { _, item in item.csv }

        serializedItems.insert("id;text;createdAt;deadline;changedAt;importance;isDone", at: 0)

        let data = serializedItems.joined(separator: "\n").data(using: .utf8)!
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

  /// This imethod allows the user to load `Task` objects from a file on the device. The method reads the JSON data
  /// from the specified file and deserializes it into an array of Any objects. It then uses the `parse(json:)` method
  /// of the `Task` class to deserialize each Task object from the array. The deserialized Task objects are
  /// then stored in the cache. The method executes asynchronously on a background thread to avoid blocking the main thread.
  /// - Parameters:
  ///   - file: A String which is the name of the file to load the Task objects.
  ///   - completion: A closure that takes in an optional Error object as its parameter. The closure is executed when the load
  ///   operation is completed. If the load operation is successful, the closure is called with a nil error parameter. If there
  ///   is an error during the load operation, the closure is called with an Error object that describes the error.
  func loadFromJSON(from file: String, completion: @escaping (Error?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
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

        let deserializedItems = json.compactMap { Task.parse(json: $0) }
        self.items = Dictionary(uniqueKeysWithValues: deserializedItems.map { ($0.id, $0) })

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

  /// This method allows the user to load `Task` objects from a CSV file on the device. The method reads the CSV
  /// data from the specified file and deserializes it into an array of `Task` objects. It then stores the
  /// deserialized `Task` objects in the cache. The method executes asynchronously on a background thread to avoid
  /// blocking the main thread.
  /// - Parameters:
  ///   - file: A String which is the name of the file to load the Task objects.
  ///   - completion: A closure that takes in an optional Error object as its parameter. The closure is executed when
  ///   the load operation is completed. If the load operation is successful, the closure is called with a nil error
  ///   parameter. If there is an error during the load operation, the closure is called with an Error object that
  ///   describes the error.
  func loadFromCSV(from file: String, completion: @escaping (Error?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
          throw FileCacheErrors.directoryNotFound
        }

        let path = directory.appending(path: "\(file).csv")
        let data = try String(contentsOf: path, encoding: .utf8)
        let rows = data.split(separator: "\n")

        var deserializedItems = [Task]()

        for i in 1 ..< rows.count {
          deserializedItems.append(Task.parse(csv: String(rows[i]))!)
        }

        self.items = Dictionary(uniqueKeysWithValues: deserializedItems.map { ($0.id, $0) })

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
}

// MARK: - FileCacheErrors

/// Is a enum that defines the possible errors that can occur during the FileCache operations. It conforms to the `Error` protocol
/// which means that it can be used to throw and catch errors.
enum FileCacheErrors: Error {
  case directoryNotFound
  case invalidData
}
