//
//  FileCacheTests.swift
//  Tests
//
//  Created by Danila Belyi on 15.06.2023.
//

@testable import To_Do_List
import XCTest

final class FileCacheTests: XCTestCase {
  var fileCache: FileCache!

  override func setUp() {
    super.setUp()
    fileCache = FileCache()
  }

  override func tearDown() {
    fileCache = nil
    super.tearDown()
  }

  func testAdd() {
    // Given
    let item = Task(id: "1", text: "smth", createdAt: Date(), importance: Importance.important, isDone: false)

    // When
    let oldItem = fileCache.add(item)

    // Then
    XCTAssertNil(oldItem)
    XCTAssertEqual(fileCache.items.count, 1)
    XCTAssertEqual(fileCache.items["1"]!.id, item.id)
  }

  func testDelete() {
    // Given
    let item = Task(id: "1", text: "smth", createdAt: Date(), importance: Importance.important, isDone: false)
    _ = fileCache.add(item)

    // When
    let deletedItem = fileCache.delete("1")

    // Then
    XCTAssertEqual(deletedItem!.id, item.id)
    XCTAssertEqual(fileCache.items.count, 0)
    XCTAssertNil(fileCache.items["1"]?.id)
  }

  func testSaveAndLoadFromJSON() {
    // Given
    let item = Task(id: "1", text: "smth", createdAt: Date(), importance: Importance.important, isDone: false)
    _ = fileCache.add(item)
    let filename = "test"

    // When
    let saveExpectation = expectation(description: "Save completion")
    fileCache.saveToJSON(to: filename) { error in
      XCTAssertNil(error)
      saveExpectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    let loadExpectation = expectation(description: "Load completion")
    fileCache.loadFromJSON(from: filename) { error in
      XCTAssertNil(error)
      loadExpectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    // Then
    XCTAssertEqual(fileCache.items.count, 1)
    XCTAssertEqual(fileCache.items["1"]!.id, item.id)
  }

  func testSaveToJSONWithNonExistingDirectory() {
    // Given
    let item = Task(id: "1", text: "smth", createdAt: Date(), importance: Importance.important, isDone: false)
    _ = fileCache.add(item)
    let filename = "nonExistingDirectory/test"

    // When
    let saveExpectation = expectation(description: "Save completion")
    fileCache.saveToJSON(to: filename) { error in
      XCTAssertNotNil(error)
      saveExpectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)
  }

  func testLoadFromJSONWithNonExistingDirectory() {
    // Given
    let filename = "nonExistingDirectory/test"

    // When
    let loadExpectation = expectation(description: "Load completion")
    fileCache.loadFromJSON(from: filename) { error in
      XCTAssertNotNil(error)
      loadExpectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    XCTAssertEqual(fileCache.items.count, 0)
  }

  func testSaveAndLoadFromJSONWithMultipleItems() {
    // Given
    let firstItem = Task(id: "1", text: "smth", createdAt: Date(), importance: Importance.important, isDone: false)
    _ = fileCache.add(firstItem)
    let secondItem = Task(id: "2", text: "cat", createdAt: Date(), importance: Importance.low, isDone: false)
    _ = fileCache.add(secondItem)
    let thirdItem = Task(id: "3", text: "watch film", createdAt: Date(), importance: Importance.low, isDone: false)
    _ = fileCache.add(thirdItem)
    let filename = "test"

    // When
    let saveExpectation = expectation(description: "Save completion")
    fileCache.saveToJSON(to: filename) { error in
      XCTAssertNil(error)
      saveExpectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    let loadExpectation = expectation(description: "Load completion")
    fileCache.loadFromJSON(from: filename) { error in
      XCTAssertNil(error)
      loadExpectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    XCTAssertEqual(fileCache.items.count, 3)
    XCTAssertEqual(fileCache.items["1"]!.id, firstItem.id)
    XCTAssertEqual(fileCache.items["2"]!.id, secondItem.id)
    XCTAssertEqual(fileCache.items["3"]!.id, thirdItem.id)
  }

  func testSaveAndLoadFromCSV() {
    // Given
    let item = Task(id: "1", text: "smth", createdAt: Date(), importance: Importance.important, isDone: false)
    _ = fileCache.add(item)
    let filename = "test"

    // When
    let saveExpectation = expectation(description: "Save completion")
    fileCache.saveToCSV(to: filename) { error in
      XCTAssertNil(error)
      saveExpectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    let loadExpectation = expectation(description: "Load completion")
    fileCache.loadFromCSV(from: filename) { error in
      XCTAssertNil(error)
      loadExpectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    // Then
    XCTAssertEqual(fileCache.items.count, 1)
    XCTAssertEqual(fileCache.items["1"]!.id, item.id)
  }

  func testSaveToCSVWithNonExistingDirectory() {
    // Given
    let item = Task(id: "1", text: "smth", createdAt: Date(), importance: Importance.important, isDone: false)
    _ = fileCache.add(item)
    let filename = "nonExistingDirectory/test"

    // When
    let saveExpectation = expectation(description: "Save completion")
    fileCache.saveToCSV(to: filename) { error in
      XCTAssertNotNil(error)
      saveExpectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)
  }

  func testLoadFromCSVWithNonExistingDirectory() {
    // Given
    let filename = "nonExistingDirectory/test"

    // When
    let loadExpectation = expectation(description: "Load completion")
    fileCache.loadFromCSV(from: filename) { error in
      XCTAssertNotNil(error)
      loadExpectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    XCTAssertEqual(fileCache.items.count, 0)
  }

  func testSaveAndLoadFromCSVWithMultipleItems() {
    // Given
    let firstItem = Task(id: "1", text: "smth", createdAt: Date(), importance: Importance.important, isDone: false)
    _ = fileCache.add(firstItem)
    let secondItem = Task(id: "2", text: "cat", createdAt: Date(), importance: Importance.low, isDone: false)
    _ = fileCache.add(secondItem)
    let thirdItem = Task(id: "3", text: "watch film", createdAt: Date(), importance: Importance.low, isDone: false)
    _ = fileCache.add(thirdItem)
    let filename = "test"

    // When
    let saveExpectation = expectation(description: "Save completion")
    fileCache.saveToCSV(to: filename) { error in
      XCTAssertNil(error)
      saveExpectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    let loadExpectation = expectation(description: "Load completion")
    fileCache.loadFromCSV(from: filename) { error in
      XCTAssertNil(error)
      loadExpectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    XCTAssertEqual(fileCache.items.count, 3)
    XCTAssertEqual(fileCache.items["1"]!.id, firstItem.id)
    XCTAssertEqual(fileCache.items["2"]!.id, secondItem.id)
    XCTAssertEqual(fileCache.items["3"]!.id, thirdItem.id)
  }
}
