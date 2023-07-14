//
//  Database.swift
//  To-Do List
//
//  Created by Danila Belyi on 08.07.2023.
//

import DTLogger
import Foundation
import SQLite

// MARK: - Database

class Database {
  private var path: String = ""
  private var connection: Connection?

  private let tasksTable = Table("tasks")
  private let idColumn = Expression<String>("id")
  private let textColumn = Expression<String>("text")
  private let createdAtColumn = Expression<Date>("created_at")
  private let deadlineColumn = Expression<Date?>("deadline")
  private let changedAtColumn = Expression<Date?>("changed_at")
  private let importanceColumn = Expression<String>("importance")
  private let isDoneColumn = Expression<Bool>("is_done")

  var tasks: [Task] = []

  init() {
    do {
      guard let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
        throw DatabaseError.invalidDirectoryPath
      }

      path = "\(documentDirectory)/db.sqlite"
      connection = try Connection(path)

      if !tableExists(tableName: "tasks") {
        createTasksTable()
      }

      SystemLogger.info("Соединение с базой данных установлено по пути: \(path)")
    } catch {
      SystemLogger.error("Не удалось инициализировать базу данных: \(error)")
    }
  }

  private func tableExists(tableName: String) -> Bool {
    do {
      guard let connection = connection else {
        throw DatabaseError.invalidConnection
      }

      let query = "SELECT name FROM sqlite_master WHERE type='table' AND name='\(tableName)'"
      let result = try connection.scalar(query)

      return result != nil
    } catch {
      SystemLogger.error("Ошибка при проверке существования таблицы \(tableName): \(error)")
      return false
    }
  }

  private func createTasksTable() {
    do {
      guard let connection = connection else {
        throw DatabaseError.invalidConnection
      }

      try connection.run(tasksTable.create { table in
        table.column(idColumn, primaryKey: true)
        table.column(textColumn)
        table.column(createdAtColumn)
        table.column(deadlineColumn)
        table.column(changedAtColumn)
        table.column(importanceColumn)
        table.column(isDoneColumn)
      })
      SystemLogger.info("Таблица Tasks успешно создана")
    } catch {
      SystemLogger.error("Не удалось создать таблицу Tasks:  \(error)")
    }
  }

  private func mapTask(from row: Row) -> Task {
    let id = row[idColumn]
    let text = row[textColumn]
    let createdAt = row[createdAtColumn]
    let deadline = row[deadlineColumn]
    let changedAt = row[changedAtColumn]
    let importance = Importance(rawValue: row[importanceColumn]) ?? .normal
    let isDone = row[isDoneColumn]

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

  func addOrUpdate(_ newTask: Task) -> Task? {
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

  func insertOrUpdateTask(task: Task) {
    do {
      guard let connection = connection else {
        throw DatabaseError.invalidConnection
      }

      let insert = tasksTable.insert(or: .replace,
                                     idColumn <- task.id,
                                     textColumn <- task.text,
                                     createdAtColumn <- task.createdAt,
                                     deadlineColumn <- task.deadline,
                                     changedAtColumn <- task.changedAt,
                                     importanceColumn <- task.importance.rawValue,
                                     isDoneColumn <- task.isDone)

      try connection.run(insert)

      _ = addOrUpdate(task)

      SystemLogger.info("Задача успешно добавлена или изменена в базе данных")
    } catch {
      SystemLogger.error("Не удалось добавить или изменить задачу в базе данных: \(error)")
    }
  }

  func deleteTask(id: String) {
    do {
      guard let connection = connection else {
        throw DatabaseError.invalidConnection
      }

      let delete = tasksTable.filter(idColumn == id).delete()

      try connection.run(delete)

      _ = self.delete(id)

      SystemLogger.info("Задача успешно удалена из базы данных")
    } catch {
      SystemLogger.error("Не удалось удалить задачу из базы данных: \(error)")
    }
  }

  func loadFromSQLite(completion: @escaping (Error?) -> Void) {
    guard let connection = connection else {
      SystemLogger.error("Загрузка данных из базы не удалась, потому что отсутствует соединение")
      return
    }
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        var loadedTasks: [Task] = []

        for taskRow in try connection.prepare(self.tasksTable) {
          let loadedTask = self.mapTask(from: taskRow)
          loadedTasks.append(loadedTask)
        }

        DispatchQueue.main.async {
          self.tasks = loadedTasks
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

// MARK: - DatabaseError

enum DatabaseError: Error {
  case invalidDirectoryPath
  case invalidConnection
}
