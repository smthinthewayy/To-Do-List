//
//  NewTaskCellView.swift
//  To-Do List
//
//  Created by Danila Belyi on 15.07.2023.
//

import SwiftUI

// MARK: - NewTaskCellView

struct NewTaskCellView: View {
  var body: some View {
    Text("Новое")
      .font(Font(Fonts.font(for: .body)))
      .foregroundColor(Color(Colors.color(for: .labelTertiary)))
      .frame(minHeight: 24)
  }
}

// MARK: - NewTaskCellView_Previews

struct NewTaskCellView_Previews: PreviewProvider {
  static var previews: some View {
    NewTaskCellView()
      .previewLayout(.sizeThatFits)
  }
}
