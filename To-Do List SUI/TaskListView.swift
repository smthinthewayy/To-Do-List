//
//  ContentView.swift
//  To-Do List SUI
//
//  Created by Danila Belyi on 15.07.2023.
//

import SwiftUI

// MARK: - TaskListView

struct TaskListView: View {
  let data = [
    TaskCellView(task: Task(text: "Купить что-то", createdAt: .now, importance: .normal, isDone: true)),
    TaskCellView(task: Task(text: "Купить что-то", createdAt: .now, importance: .normal, isDone: true)),
    TaskCellView(task: Task(text: "Задание", createdAt: .now, deadline: .now + 24 * 60 * 60, importance: .normal, isDone: false)),
    TaskCellView(task: Task(text: "Купить что-то", createdAt: .now, importance: .important, isDone: false)),
    TaskCellView(task: Task(text: "Купить что-то", createdAt: .now, importance: .normal, isDone: true)),
    TaskCellView(task: Task(text: "сделать зарядку", createdAt: .now, importance: .normal, isDone: false)),
    TaskCellView(task: Task(
      text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы пока не понял",
      createdAt: .now,
      importance: .normal,
      isDone: false
    )),
  ]

  @State private var showTaskDetails = false
  @State private var selectedTask: Task = .init(text: "", createdAt: .now, importance: .normal, isDone: false)

  var body: some View {
    NavigationStack {
      ZStack {
        List {
          Section(header: HStack {
            Text("Выполнено — 3")
              .font(Font(Fonts.font(for: .body)))
              .foregroundColor(Color(uiColor: Colors.color(for: .labelTertiary)))
              .textCase(nil)
            Spacer()
            Button {} label: {
              Text("Показать")
                .font(Font(Fonts.font(for: .headline)))
                .foregroundColor(Color(Colors.color(for: .blue)))
                .textCase(nil)
            }
          }
          .padding(.bottom, 12)) {
            ForEach(data, id: \.task.id) { task in
              task
                .contentShape(Rectangle())
                .listRowBackground(Color(uiColor: Colors.color(for: .backSecondary)))
                .swipeActions(edge: .leading) {
                  Button(action: {}) {
                    Image(uiImage: Images.image(for: .circleCheckmark))
                  }
                  .tint(Color(Colors.color(for: .green)))
                }
                .swipeActions(edge: .trailing) {
                  Button(action: {}) {
                    Image(uiImage: Images.image(for: .trash))
                  }
                  .tint(Color(Colors.color(for: .red)))
                  Button(action: {}) {
                    Image(uiImage: Images.image(for: .circleInfo))
                  }
                  .tint(Color(Colors.color(for: .grayLight)))
                }
                .padding(.top, 16)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                .onTapGesture {
                  selectedTask = task.task
                  showTaskDetails.toggle()
                }
                .listRowSeparator(.hidden)
            }

            Button {
              selectedTask = Task(text: "Что надо сделать?", createdAt: .now, importance: .normal, isDone: false)
              showTaskDetails.toggle()
            } label: {
              Text("Новое")
                .foregroundColor(Color(uiColor: Colors.color(for: .labelTertiary)))
                .padding(.vertical, 8)
                .padding(.leading, 36)
            }
            .listRowBackground(Color(uiColor: Colors.color(for: .backSecondary)))
          }
        }
        .sheet(isPresented: $showTaskDetails) {
          TaskDetails(task: $selectedTask)
        }
        .navigationTitle("Мои дела")
        .scrollContentBackground(.hidden)
        .background(Color(uiColor: Colors.color(for: .backPrimary)))
        .foregroundColor(Color(uiColor: Colors.color(for: .backSecondary)))

        VStack {
          Spacer()
          Button {
            selectedTask = Task(text: "Что надо сделать?", createdAt: .now, importance: .normal, isDone: false)
            showTaskDetails.toggle()
          } label: {
            Image(uiImage: Images.image(for: .addButton))
          }
          .shadow(color: Color(red: 0, green: 0.19, blue: 0.4).opacity(0.3), radius: 10, x: 0, y: 8)
          .padding(.bottom, -10)
        }
      }
    }
    .onAppear {
      UINavigationBar.appearance().layoutMargins.left = 32
    }
  }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    TaskListView()
  }
}
