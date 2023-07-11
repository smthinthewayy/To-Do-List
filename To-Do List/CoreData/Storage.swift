//
//  Storage.swift
//  To-Do List
//
//  Created by Danila Belyi on 11.07.2023.
//

import CoreData
import DTLogger
import Foundation

class Storage {
  static let shared = Storage()

  var tasks: [Task] = []

  private lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Task")
    container.loadPersistentStores(completionHandler: { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()

  lazy var readContext: NSManagedObjectContext = {
    let context = persistentContainer.viewContext
    context.automaticallyMergesChangesFromParent = true
    return context
  }()

  lazy var writeContext: NSManagedObjectContext = {
    let context = persistentContainer.newBackgroundContext()
    context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    return context
  }()

//  func fetchTask(withID id: String) -> TaskEntity? {
//    let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
//    request.predicate = NSPredicate(format: "id == %@", id)
//
//    do {
//      let tasks = try readContext.fetch(request)
//      SystemLogger.info("Объект Task получен из CoreData под ID: \(tasks.first?.id ?? "")")
//      return tasks.first
//    } catch {
//      SystemLogger.error("Не удалось получить объект Task из CoreData. \(error)")
//      return nil
//    }
//  }

  func fetchAllTasks(completion: @escaping (Error?) -> Void) {
    let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

    do {
      let taskEntities = try readContext.fetch(request)
      SystemLogger.info("Получено \(taskEntities.count) объектов TaskEntity из CoreData")
      tasks = taskEntities.map { convertTaskEntityToTask($0) }
      completion(nil)
    } catch {
      SystemLogger.error("Не удалось получить объекты Task из CoreData. \(error)")
      completion(error)
    }
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

  func addTask(_ task: Task, context: NSManagedObjectContext) {
    guard let taskEntity = NSEntityDescription.insertNewObject(
      forEntityName: String(describing: TaskEntity.self),
      into: context
    ) as? TaskEntity else {
      SystemLogger.error("Не удалось преобразовать managedObject в TaskEntity")
      return
    }

    taskEntity.id = task.id
    taskEntity.text = task.text
    taskEntity.createdAt = task.createdAt
    taskEntity.deadline = task.deadline
    taskEntity.changedAt = task.changedAt
    taskEntity.importance = task.importance.rawValue
    taskEntity.isDone = task.isDone

    SystemLogger.info("Идет сохранение объекта Task в CoreData")

    do {
      try context.save()
      SystemLogger.info("Объект Task успешно сохранен в CoreData")
      _ = addOrUpdate(task)
    } catch {
      SystemLogger.error("Не удалось сохранить объект Task в CoreData. \(error)")
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

  func deleteTask(withID id: String, context: NSManagedObjectContext) {
    let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", id)

    do {
      let tasks = try context.fetch(request)
      guard let task = tasks.first else {
        SystemLogger.warning("Не найден объект Task с id: \(id)")
        return
      }

      context.delete(task)

      do {
        try context.save()
        SystemLogger.info("Объект Task с id: \(id) успешно удален из CoreData")
        _ = delete(id)
      } catch {
        SystemLogger.error("Не удалось сохранить контекст после удаления объекта Task с id: \(id). \(error)")
      }
    } catch {
      SystemLogger.error("Не удалось найти объект Task с id: \(id) в CoreData. \(error)")
    }
  }

  func convertTaskEntityToTask(_ taskEntity: TaskEntity) -> Task {
    let id = taskEntity.id ?? ""
    let text = taskEntity.text ?? ""
    let createdAt = taskEntity
      .createdAt ?? Date()
    let deadline = taskEntity
      .deadline ?? nil
    let changedAt = taskEntity
      .changedAt ?? nil
    let importanceRawValue = taskEntity
      .importance ?? ""
    let importance = Importance(rawValue: importanceRawValue) ?? .normal
    let isDone = taskEntity.isDone

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
