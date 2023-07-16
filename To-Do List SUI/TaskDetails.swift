//
//  TaskDetails.swift
//  To-Do List SUI
//
//  Created by Danila Belyi on 15.07.2023.
//

import SwiftUI

// MARK: - TaskDetails

struct TaskDetails: View {
  @State private var editedText: String
  @State private var selectedSegment = 1
  @State private var isToggled = false
  let task: Task

  init(task: Task) {
    self.task = task
    _editedText = State(initialValue: task.text == "" ? "Что надо сделать?" : task.text)
  }

  var body: some View {
    VStack(spacing: 16) {
      TextEditor(text: $editedText)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .foregroundColor(task
          .text == "" ? Color(uiColor: Colors.color(for: .labelTertiary)) : Color(uiColor: Colors.color(for: .labelPrimary)))
        .font(Font(Fonts.font(for: .body)))
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .frame(height: 120)

      ScrollView {
        HStack {
          Text("Важность")
            .padding(.leading, 16)
            .font(Font(Fonts.font(for: .body)))

          Spacer()

          Picker("", selection: $selectedSegment) {
            Image(uiImage: Images.image(for: .lowImportance).withRenderingMode(.alwaysOriginal))
              .tag(0)
            Text("нет")
              .tag(1)
              .font(Font(Fonts.font(for: .mediumSubhead)))
            Image(uiImage: Images.image(for: .highImportance).withRenderingMode(.alwaysOriginal))
              .tag(2)
          }
          .padding(.trailing, 16)
          .pickerStyle(.segmented)
          .frame(width: 150)
        }
//        .background(.gray)
        .padding(.top, 10)
//        .frame(height: 56)

        Divider()
          .padding(.leading, 16)
          .padding(.trailing, 16)

        HStack {
          Text("Сделать до")
            .padding(.leading, 16)
            .font(Font(Fonts.font(for: .body)))

          Spacer()

          Toggle("", isOn: $isToggled)
            .padding(.trailing, 18)
        }
        .padding(.top, 4)
      }
      .scrollDisabled(true)
      .background(Color(Colors.color(for: .backSecondary)))
      .cornerRadius(16)
      .padding(.leading, 16)
      .padding(.trailing, 16)
      .frame(height: 113)

//      List {
//        HStack {
//          Text("Важность")
//            .font(Font(Fonts.font(for: .body)))
//
//          Spacer()
//
//          Picker("", selection: $selectedSegment) {
//            Image(uiImage: Images.image(for: .lowImportance))
//              .renderingMode(.original)
//              .tag(0)
//            Text("нет")
//              .tag(1)
//              .font(Font(Fonts.font(for: .mediumSubhead)))
//            Image(uiImage: Images.image(for: .highImportance))
//              .renderingMode(.original)
//              .tag(2)
//          }
//          .pickerStyle(.segmented)
//          .frame(width: 150)
//        }
//        .frame(height: 24)
//
//        HStack {
//          Text("Сделать до")
//            .font(Font(Fonts.font(for: .body)))
//        }
//        .frame(height: 24)
//      }
//      .scrollContentBackground(.hidden)
//      .background(Color(Colors.color(for: .backPrimary)))
//      .background(Color(Colors.color(for: .gray)))

//      .scrollDisabled(true)
//      .frame(height: 123)

      Button(action: {}) {
        Text("Удалить")
          .frame(width: 343, height: 56)
      }
      .disabled(true)
      .foregroundColor(Color(uiColor: Colors.color(for: .labelTertiary)))
      .background(Color(uiColor: Colors.color(for: .backSecondary)))
      .cornerRadius(16)

      Spacer()
    }
    .background(Color(Colors.color(for: .backPrimary)))
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
