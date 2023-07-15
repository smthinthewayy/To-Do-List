//
//  TaskDetails.swift
//  To-Do List SUI
//
//  Created by Danila Belyi on 15.07.2023.
//

import SwiftUI

// MARK: - TaskDetails

struct TaskDetails: View {
  let task: Task

  var body: some View {
    Text(task.text)
  }
}

// MARK: - TaskDetails_Previews

struct TaskDetails_Previews: PreviewProvider {
  static var previews: some View {
    TaskDetails(task: Task(
      text: "Покормить кота",
      createdAt: .now,
//      deadline: .now + 24 * 60 * 60,
      importance: .normal,
      isDone: false
    ))
  }
}
