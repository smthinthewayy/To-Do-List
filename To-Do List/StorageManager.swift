//
//  StorageManager.swift
//  To-Do List
//
//  Created by Danila Belyi on 09.07.2023.
//

import Foundation

// MARK: - StorageManager

class StorageManager {
  var selectedStorage: StorageType = .database
  var fileCache: FileCache?
  var database: Database?

  init() {
    switch selectedStorage {
    case .fileCache:
      fileCache = FileCache()
    case .database:
      database = Database()
    }
  }
}

// MARK: - StorageType

enum StorageType {
  case fileCache
  case database
}
