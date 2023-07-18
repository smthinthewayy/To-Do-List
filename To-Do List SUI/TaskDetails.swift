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
  @State private var showedDate = .now + 24 * 60 * 60
  @State private var showCalendar = false
  @Environment(\.dismiss) private var dismiss
  let task: Task

  init(task: Task) {
    self.task = task
    _editedText = State(initialValue: task.text == "" ? "Что надо сделать?" : task.text)
    if let deadline = task.deadline {
      showedDate = deadline
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
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
            .frame(height: 120)

          VStack {
            HStack {
              Text("Важность")
                .font(Font(Fonts.font(for: .body)))
                .foregroundColor(Color(Colors.color(for: .labelPrimary)))

              Spacer()

              Picker("", selection: $selectedSegment) {
                Image(uiImage: Images.image(for: .lowImportance))
                  .tag(0)
                Text("нет")
                  .tag(1)
                  .font(Font(Fonts.font(for: .mediumSubhead)))
                Image(uiImage: Images.image(for: .highImportance))
                  .tag(2)
              }
              .pickerStyle(.segmented)
              .frame(width: 150)
            }

            Divider()

            HStack {
              VStack(alignment: .leading) {
                Text("Сделать до")
                  .font(Font(Fonts.font(for: .body)))
                  .foregroundColor(Color(Colors.color(for: .labelPrimary)))

                if isToggled {
                  Button {
                    withAnimation {
                      showCalendar = true
                    }
                  } label: {
                    Text("\(formatDate(for: showedDate))")
                      .foregroundColor(Color(uiColor: Colors.color(for: .blue)))
                      .font(Font(Fonts.font(for: .footnote)))
                  }
                }
              }

              Spacer()

              Toggle("", isOn: $isToggled)
                .padding(.trailing, 2)
                .onChange(of: isToggled) { _ in
                  showCalendar = false
                }
            }
            .frame(height: 40)
            .onAppear {
              if task.deadline != nil {
                isToggled = true
              } else {
                isToggled = false
              }
            }

            if showCalendar {
              Divider()
              DatePicker(
                "Start Date",
                selection: $showedDate,
                displayedComponents: [.date]
              )
              .datePickerStyle(.graphical)
              .padding(.leading, -8)
              .padding(.trailing, -8)
              .onChange(of: showedDate) { newValue in
                showedDate = newValue
                showCalendar = false
              }
            }
          }
          .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
          .background(Color(Colors.color(for: .backSecondary)))
          .cornerRadius(16)

          Button(action: {}) {
            Text("Удалить")
          }
          .frame(maxWidth: .infinity, minHeight: 56)
          .disabled(true)
          .foregroundColor(Color(uiColor: Colors.color(for: .labelTertiary)))
          .background(Color(uiColor: Colors.color(for: .backSecondary)))
          .cornerRadius(16)

          Spacer()
        }
        .background(Color(Colors.color(for: .backPrimary)))
        .padding([.leading, .trailing, .top], 16)
      }
      .scrollContentBackground(.hidden)
      .background(Color(Colors.color(for: .backPrimary)))
      .navigationTitle("Дело")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Text("Отменить")
              .font(Font(Fonts.font(for: .body)))
              .foregroundColor(Color(Colors.color(for: .blue)))
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {} label: {
            Text("Сохранить")
              .font(Font(Fonts.font(for: .headline)))
              .foregroundColor(Color(Colors.color(for: .blue)))
          }
        }
      }
//      .padding([.leading, .trailing], 16)
    }
  }
}

// MARK: - TaskDetails_Previews

struct TaskDetails_Previews: PreviewProvider {
  static var previews: some View {
    TaskDetails(task: Task(
      text: "Покормить кота",
      createdAt: .now,
      deadline: .now + 24 * 60 * 60 * 3,
      importance: .normal,
      isDone: false
    ))
  }
}
