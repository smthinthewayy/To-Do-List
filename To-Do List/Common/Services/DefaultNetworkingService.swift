//
//  DefaultNetworkingService.swift
//  To-Do List
//
//  Created by Danila Belyi on 02.07.2023.
//

import DTLogger
import Foundation
import UIKit

// MARK: - NetworkingService

protocol NetworkingService {
  func request<T: Codable>(
    url: URL,
    method: String,
    headers: [String: String]?,
    parameters: [String: Any]?,
    bearerToken: String,
    timeoutInterval: TimeInterval,
    task: NetworkTask?,
    tasksList: [NetworkTask]?,
    completion: @escaping (Result<T, Error>) -> Void
  )
}

// MARK: - NetworkTask

struct NetworkTask: Codable {
  var id: String
  var text: String
  var importance: String
  var deadline: Int64?
  var done: Bool
  var color: String?
  var createdAt: Int64
  var changedAt: Int64
  var lastUpdatedBy: String
}

// MARK: - ListResponse

struct ListResponse: Codable {
  let status: String
  let list: [NetworkTask]
  let revision: Int32
}

// MARK: - ElementResponse

struct ElementResponse: Codable {
  let status: String
  let element: NetworkTask
  let revision: Int32
}

// MARK: - Tasks

struct Tasks {
  var tasks: [Task] = []
  var isDirty: Bool = false
}

// MARK: - DefaultNetworkingService

final class DefaultNetworkingService: NetworkingService {
  let baseURL: URL
  let bearerToken: String
  var revision: Int32?
  let serialQueue = DispatchQueue(label: "com.To-Do_list.serialQueue", qos: .userInteractive)

  init(baseURL: URL, bearerToken: String) {
    self.baseURL = baseURL
    self.bearerToken = bearerToken
  }

  func getRevision(completion: @escaping (Result<Int32, Error>) -> Void) {
    if let revision = self.revision {
      completion(.success(revision))
    } else {
      getTasksList { result in
        switch result {
        case let .success(response):
          self.revision = response.revision
          completion(.success(response.revision))
        case let .failure(error):
          completion(.failure(error))
        }
      }
    }
  }

  func request<T>(
    url: URL,
    method: String,
    headers: [String: String]?,
    parameters: [String: Any]?,
    bearerToken: String,
    timeoutInterval: TimeInterval = 60,
    task: NetworkTask? = nil,
    tasksList: [NetworkTask]? = nil,
    completion: @escaping (Result<T, Error>) -> Void
  ) where T: Codable {
    let request = buildRequest(
      url: url,
      method: method,
      headers: headers,
      parameters: parameters,
      bearerToken: bearerToken,
      task: task,
      tasksList: tasksList
    )

    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = timeoutInterval
    let session = URLSession(configuration: config)

    let task = session.dataTask(with: request) { data, response, error in
      if let error = error {
        SystemLogger
          .error(
            "Возможно отсутствует подключение к сети или происходит проблема с установлением соединения с сервером"
          )
        SystemLogger.error("\(error)")
        completion(.failure(error))
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        SystemLogger.error("response не может быть приведен к типу ﻿HTTPURLResponse")
        completion(.failure(URLError(.badServerResponse)))
        return
      }

      let statusCode = httpResponse.statusCode

      if statusCode < 200 || statusCode >= 300 {
        let errorDescription = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        let userInfo = [NSLocalizedDescriptionKey: errorDescription]
        let httpError = NSError(domain: "HTTP", code: statusCode, userInfo: userInfo)
        SystemLogger.error("HTTP-статус код ответа на запрос не находится в диапазоне успешных (200-299)")
        completion(.failure(httpError))
        return
      }

      if let data = data {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
          let parsedData = try decoder.decode(T.self, from: data)
          SystemLogger.info("Данные были успешно преобразованы в указанный тип ﻿\(T.self)")
          if let currentRevision = self.revision {
            self.revision = currentRevision + 1
          }
          completion(.success(parsedData))
        } catch {
          SystemLogger.error("Ошибка при попытке декодировать ﻿data в указанный тип ﻿\(T.self)")
          completion(.failure(error))
        }
      }
    }

    task.resume()
  }

  private func buildRequest(
    url: URL,
    method: String,
    headers: [String: String]?,
    parameters: [String: Any]?,
    bearerToken: String,
    task: NetworkTask? = nil,
    tasksList: [NetworkTask]? = nil
  ) -> URLRequest {
    var request = URLRequest(url: url)

    request.httpMethod = method

    if let parameters = parameters {
      let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
      if jsonData == nil {
        SystemLogger.error("Переданные параметры не могут быть преобразованы в формат JSON")
      }
      request.httpBody = jsonData
    }

    if let headers = headers {
      for (key, value) in headers {
        request.setValue(value, forHTTPHeaderField: key)
      }
    }

    request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

    if method == "POST" || method == "PUT" {
      if let task = task {
        let wrappedData: [String: NetworkTask] = ["element": task]
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try? encoder.encode(wrappedData)
        if let data = data {
          request.httpBody = data
        }
      }
    }

    if method == "PATCH" {
      if let tasksList = tasksList {
        let wrappedData: [String: [NetworkTask]] = ["list": tasksList]
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try? encoder.encode(wrappedData)
        if let data = data {
          request.httpBody = data
        }
      }
    }

    return request
  }

  func getTasksList(completion: @escaping (Result<ListResponse, Error>) -> Void) {
    serialQueue.async { [self] in
      let url = URL(string: "\(baseURL)/list")!
      let method = "GET"
      let parameters: [String: Any]? = nil
      let headers: [String: String]? = nil
      request(
        url: url,
        method: method,
        headers: headers,
        parameters: parameters,
        bearerToken: bearerToken,
        timeoutInterval: TimeInterval(5),
        completion: completion
      )
    }
  }

  func addTaskToList(task: NetworkTask, completion: @escaping (Result<ElementResponse, Error>) -> Void) {
    serialQueue.async { [self] in
      getRevision { [self] result in
        switch result {
        case .success:
          guard let revision = self.revision else {
            SystemLogger.error("Ошибка при попытке получить ревизию данных")
            return
          }
          SystemLogger.info("Ревизия данных успешно получена, revision = \(revision)")
          let url = URL(string: "\(baseURL)/list")!
          let method = "POST"
          let parameters: [String: Any]? = nil
          let headers = ["X-Last-Known-Revision": "\(revision)"]
          request(
            url: url,
            method: method,
            headers: headers,
            parameters: parameters,
            bearerToken: bearerToken,
            task: task,
            completion: completion
          )
        case let .failure(error):
          print(error)
        }
      }
    }
  }

  func getTaskFromList(for id: String, completion: @escaping (Result<ElementResponse, Error>) -> Void) {
    serialQueue.async { [self] in
      let url = URL(string: "\(baseURL)/list/\(id)")!
      let method = "GET"
      let parameters: [String: Any]? = nil
      let headers: [String: String]? = nil
      request(
        url: url,
        method: method,
        headers: headers,
        parameters: parameters,
        bearerToken: bearerToken,
        timeoutInterval: TimeInterval(5),
        completion: completion
      )
    }
  }

  func deleteTaskFromList(for id: String, completion: @escaping (Result<ElementResponse, Error>) -> Void) {
    serialQueue.async { [self] in
      getRevision { [self] result in
        switch result {
        case .success:
          guard let revision = self.revision else {
            SystemLogger.error("Ошибка при попытке получить ревизию данных")
            return
          }
          SystemLogger.info("Ревизия данных успешно получена, revision = \(revision)")
          let url = URL(string: "\(baseURL)/list/\(id)")!
          let method = "DELETE"
          let parameters: [String: Any]? = nil
          let headers = ["X-Last-Known-Revision": "\(revision)"]
          request(
            url: url,
            method: method,
            headers: headers,
            parameters: parameters,
            bearerToken: bearerToken,
            completion: completion
          )
        case let .failure(error):
          print(error)
        }
      }
    }
  }

  func editTask(task: NetworkTask, completion: @escaping (Result<ElementResponse, Error>) -> Void) {
    serialQueue.async { [self] in
      getRevision { [self] result in
        switch result {
        case .success:
          guard let revision = self.revision else {
            SystemLogger.error("Ошибка при попытке получить ревизию данных")
            return
          }
          SystemLogger.info("Ревизия данных успешно получена, revision = \(revision)")
          let url = URL(string: "\(baseURL)/list/\(task.id)")!
          let method = "PUT"
          let parameters: [String: Any]? = nil
          let headers = ["X-Last-Known-Revision": "\(revision)"]
          request(
            url: url,
            method: method,
            headers: headers,
            parameters: parameters,
            bearerToken: bearerToken,
            task: task,
            completion: completion
          )
        case let .failure(error):
          print(error)
        }
      }
    }
  }

  func updateList(_ tasksList: [NetworkTask], completion: @escaping (Result<ListResponse, Error>) -> Void) {
    serialQueue.async { [self] in
      getRevision { [self] result in
        switch result {
        case .success:
          guard let revision = self.revision else {
            SystemLogger.error("Ошибка при попытке получить ревизию данных")
            return
          }
          SystemLogger.info("Ревизия данных успешно получена, revision = \(revision)")
          let url = URL(string: "\(baseURL)/list")!
          let method = "PATCH"
          let parameters: [String: Any]? = nil
          let headers = ["X-Last-Known-Revision": "\(revision)"]
          request(
            url: url,
            method: method,
            headers: headers,
            parameters: parameters,
            bearerToken: bearerToken,
            tasksList: tasksList,
            completion: completion
          )
        case let .failure(error):
          print(error)
        }
      }
    }
  }

  func convertToTask(from networkTask: NetworkTask) -> Task {
    var task = Task(
      id: networkTask.id,
      text: networkTask.text,
      createdAt: Date(timeIntervalSince1970: TimeInterval(networkTask.createdAt)),
      changedAt: Date(timeIntervalSince1970: TimeInterval(networkTask.changedAt)),
      importance: .normal,
      isDone: networkTask.done
    )

    switch networkTask.importance {
    case "low":
      task.importance = .low
    case "important":
      task.importance = .important
    default:
      task.importance = .normal
    }

    if let deadline = networkTask.deadline {
      task.deadline = Date(timeIntervalSince1970: TimeInterval(deadline))
    }

    return task
  }

  func convertToNetworkTask(from task: Task) -> NetworkTask {
    var networkTask = NetworkTask(
      id: task.id,
      text: task.text,
      importance: "basic",
      deadline: nil,
      done: task.isDone,
      color: nil,
      createdAt: Int64(task.createdAt.timeIntervalSince1970),
      changedAt: 0,
      lastUpdatedBy: UIDevice.current.name
    )

    if let deadline = task.deadline {
      networkTask.deadline = Int64(deadline.timeIntervalSince1970)
    }

    if let changedAt = task.changedAt {
      networkTask.changedAt = Int64(changedAt.timeIntervalSince1970)
    }

    switch task.importance {
    case .low:
      networkTask.importance = "low"
    case .important:
      networkTask.importance = "important"
    default:
      networkTask.importance = "basic"
    }

    return networkTask
  }
}
