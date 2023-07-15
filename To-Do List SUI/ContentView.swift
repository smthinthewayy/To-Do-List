//
//  ContentView.swift
//  To-Do List SUI
//
//  Created by Danila Belyi on 15.07.2023.
//

import SwiftUI

// MARK: - ContentView

struct ContentView: View {
  let data = [
    TaskCellView(task: Task(text: "Покормить кота", createdAt: .now, importance: .normal, isDone: false)),
    TaskCellView(task: Task(text: "Погладить собаку", createdAt: .now, importance: .important, isDone: true)),
    TaskCellView(task: Task(text: "Поняшить капибару", createdAt: .now, importance: .low, isDone: false)),
    TaskCellView(task: Task(text: "Вкусно покушать", createdAt: .now, deadline: .now + 24 * 60 * 60, importance: .normal, isDone: false)),
    TaskCellView(task: Task(text: "Вредно покушать", createdAt: .now, deadline: .now + 24 * 60 * 60, importance: .low, isDone: true)),
    TaskCellView(task: Task(
      text: "Очень много текста ну вот прям мега супер дупер ультра гипер экстра пета кила декта гига много",
      createdAt: .now,
      deadline: .now + 24 * 60 * 60 * 3,
      importance: .normal,
      isDone: false
    )),
  ]

  var body: some View {
    ZStack {
      Color(uiColor: Colors.color(for: .backPrimary))
      NavigationStack {
        List {
          Section(header: HStack {
            Text("Выполнено — 2")
              .font(Font(Fonts.font(for: .body)))
              .foregroundColor(Color(uiColor: Colors.color(for: .labelTertiary)))
              .textCase(nil)
            Spacer()
            Button {
              print("sfsdf")
            } label: {
              Text("Показать")
                .font(Font(Fonts.font(for: .headline)))
                .foregroundColor(Color(Colors.color(for: .blue)))
                .textCase(nil)
            }
          }
          .padding(.bottom, 12)) {
            ForEach(data, id: \.task.id) { item in
              item
                .padding(.top, 16)
                .padding(.bottom, 16)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
          }
        }
        .navigationTitle("Мои дела")
      }
    }
  }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
