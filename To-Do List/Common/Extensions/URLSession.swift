//
//  URLSession.swift
//  To-Do List
//
//  Created by Danila Belyi on 06.07.2023.
//

import Foundation

extension URLSession {
  func dataTask(for request: URLRequest) async throws -> (Data, URLResponse) {
    var task: URLSessionDataTask?
    // задаем обработчик отмены задачи
    return try await withTaskCancellationHandler {
      // создаем продолжение асинхронной функции
      try await withCheckedThrowingContinuation { continuation in
        task = self.dataTask(with: request) { data, response, error in
          if let error = error {
            continuation.resume(throwing: error)
          } else if let data = data, let response = response {
            continuation.resume(returning: (data, response))
          } else {
            let error = NSError(domain: "https://beta.mrdekk.ru/todobackend", code: -1, userInfo: nil)
            continuation.resume(throwing: error)
          }
        }
        task?.resume()
      }
    } onCancel: { [weak task] in
      task?.cancel()
    }
  }
}
