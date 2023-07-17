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
  @State private var date = Date()
  let task: Task

  init(task: Task) {
    self.task = task
    _editedText = State(initialValue: task.text == "" ? "Что надо сделать?" : task.text)
  }

  var body: some View {
    VStack(spacing: 16) {
      TextEditor(text: $editedText)
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .scrollContentBackground(.hidden)
        .background(Color(Colors.color(for: .backSecondary)))
        .tint(Color(Colors.color(for: .red)))
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
        .padding(.top, 10)

        Divider()
          .padding(.leading, 16)
          .padding(.trailing, 16)

        HStack {
          VStack(alignment: .leading) {
            Text("Сделать до")
              .padding(.leading, 16)
              .font(Font(Fonts.font(for: .body)))

            if isToggled {
              if let deadline = task.deadline {
                Text("\(formatDate(for: task.deadline))")
                  .padding(.leading, 16)
                  .foregroundColor(Color(uiColor: Colors.color(for: .blue)))
                  .font(Font(Fonts.font(for: .footnote)))
              } else {
                Text("\(formatDate(for: .now + 24 * 60 * 60))")
                  .padding(.leading, 16)
                  .foregroundColor(Color(uiColor: Colors.color(for: .blue)))
                  .font(Font(Fonts.font(for: .footnote)))
              }
            }
          }

          Spacer()

          Toggle("", isOn: $isToggled)
            .padding(.trailing, 18)
        }
        .frame(height: 40)
        .padding(.top, 2)
        .onAppear {
          if task.deadline != nil {
            isToggled = true
          } else {
            isToggled = false
          }
        }

        Divider()
          .padding(.leading, 16)
          .padding(.trailing, 16)

        DatePicker(
          "Start Date",
          selection: $date,
          displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .padding(.leading, 8)
        .padding(.trailing, 8)
      }
      .scrollDisabled(true)
      .background(Color(Colors.color(for: .backSecondary)))
      .cornerRadius(16)
      .padding(.leading, 16)
      .padding(.trailing, 16)
      .frame(height: 435)

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
      deadline: .now + 24 * 60 * 60 * 10,
      importance: .normal,
      isDone: false
    ))
  }
}
