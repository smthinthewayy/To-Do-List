//
//  TaskCell.swift
//  To-Do List SUI
//
//  Created by Danila Belyi on 15.07.2023.
//

import SwiftUI

// MARK: - TaskCellView

struct TaskCellView: View {
  let task: Task

  var body: some View {
    VStack {
      HStack {
        Image(uiImage: Images
          .image(for: task.importance == .important && task.isDone == false ? .RBhighPriority : (task.isDone ? .RBon : .RBoff)))
          .resizable()
          .frame(width: 24, height: 24)
        VStack(alignment: .leading, spacing: 0) {
          HStack(spacing: 2) {
            if task.importance != .normal {
              Image(uiImage: Images.image(for: task.importance == .important ? .highImportance : .lowImportance))
            }
            Text(task.text)
              .font(Font(Fonts.font(for: .body)))
              .lineLimit(3)
              .strikethrough(task.isDone, color: Color(uiColor: Colors.color(for: .labelTertiary)))
              .foregroundColor(task
                .isDone ? Color(uiColor: Colors.color(for: .labelTertiary)) : Color(uiColor: Colors.color(for: .labelPrimary)))
          }
          if let deadline = task.deadline {
            HStack(alignment: .center, spacing: 2) {
              Image(uiImage: Images.image(for: .calendar))
              Text(formatDateWithoutYear(for: deadline))
                .foregroundColor(Color(uiColor: Colors.color(for: .labelTertiary)))
                .font(Font(Fonts.font(for: .subhead)))
            }
          }
        }
        Spacer()
        Image(uiImage: Images.image(for: .chevron))
      }
    }
    .frame(minHeight: 24)
    .background(Color(uiColor: Colors.color(for: .backSecondary)))
  }
}

// MARK: - TaskCellView_Previews

struct TaskCellView_Previews: PreviewProvider {
  static var previews: some View {
    TaskCellView(task: Task(
      text: "Покормить кота",
      createdAt: .now,
//      deadline: .now + 24 * 60 * 60,
      importance: .normal,
      isDone: false
    ))
    .previewLayout(.sizeThatFits)
  }
}
