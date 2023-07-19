//
//  TaskDetails.swift
//  To-Do List SUI
//
//  Created by Danila Belyi on 15.07.2023.
//

import SwiftUI

// MARK: - TaskDetails

struct TaskDetails: View {
  @State private var selectedSegment = 1
  @State private var isToggled = false
  @State private var showedDate = Date()
  @State private var showCalendar = false
  @Environment(\.dismiss) private var dismiss
  @Binding var task: Task

  init(task: Binding<Task>) {
    _isToggled = State(initialValue: task.wrappedValue.deadline == nil ? false : true)
    _showedDate = State(initialValue: task.wrappedValue.deadline ?? .now + 24 * 60 * 60)
    _task = task
    switch task.wrappedValue.importance {
    case .low:
      _selectedSegment = State(initialValue: 0)
    case .important:
      _selectedSegment = State(initialValue: 2)
    default:
      _selectedSegment = State(initialValue: 1)
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          TextEditor(text: $task.text)
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .scrollContentBackground(.hidden)
            .background(Color(Colors.color(for: .backSecondary)))
            .tint(Color(Colors.color(for: .red)))
            .cornerRadius(16)
            .foregroundColor(task
              .text == "Что надо сделать?" ? Color(uiColor: Colors.color(for: .labelTertiary)) :
              Color(uiColor: Colors.color(for: .labelPrimary)))
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
              Toggle(isOn: $isToggled) {
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
              .onAppear {
                if task.deadline != nil {
                  isToggled = true
                } else {
                  isToggled = false
                }
              }
              .onChange(of: isToggled) { _ in
                withAnimation {
                  showCalendar = false
                }
              }
              .animation(.easeOut(duration: 0.2), value: isToggled)
              .frame(height: 40)
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
                withAnimation {
                  showedDate = newValue
                  showCalendar = false
                }
              }
            }
          }
          .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
          .background(Color(Colors.color(for: .backSecondary)))
          .cornerRadius(16)

          Button {
            dismiss()
          } label: {
            Text("Удалить")
              .foregroundColor(task
                .text == "Что надо сделать?" ? Color(uiColor: Colors.color(for: .labelTertiary)) : Color(uiColor: Colors.color(for: .red)))
              .frame(maxWidth: .infinity, minHeight: 56)
          }
          .disabled(task.text == "Что надо сделать?" ? true : false)
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
          Button {
            dismiss()
          } label: {
            Text("Сохранить")
              .font(Font(Fonts.font(for: .headline)))
              .foregroundColor(Color(uiColor: Colors.color(for: .blue)))
//              .foregroundColor(task
//                .text == "Что надо сделать?" ? Color(uiColor: Colors.color(for: .labelTertiary)) : Color(uiColor: Colors.color(for:
//                .blue)))
              .frame(maxWidth: .infinity, minHeight: 56)
          }
//          .disabled(task.text == "Что надо сделать?" ? true : false)
        }
      }
    }
  }
}

// MARK: - TaskDetails_Previews

struct TaskDetails_Previews: PreviewProvider {
  static var previews: some View {
    let task = Task(
      text: "Покормить кота",
      createdAt: .now,
      deadline: .now + 24 * 60 * 60 * 3,
      importance: .important,
      isDone: false
    )
    return TaskDetails(task: .constant(task))
  }
}
