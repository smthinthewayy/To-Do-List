//
//  URLSession.swift
//  To-Do List
//
//  Created by Danila Belyi on 05.07.2023.
//

import UIKit

extension URLSession {
  func dataTask(for request: URLRequest) async throws -> (Data, URLResponse) {
    return try await withCheckedThrowingContinuation { continuation in
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
          continuation.resume(throwing: error)
        } else if let data = data, let response = response {
          continuation.resume(returning: (data, response))
        } else {
          let error = NSError(domain: "https://beta.mrdekk.ru/todobackend", code: -1, userInfo: nil)
          continuation.resume(throwing: error)
        }
      }

      task.resume()
    }
  }
}
