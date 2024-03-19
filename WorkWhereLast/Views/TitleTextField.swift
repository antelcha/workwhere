//
//  TitleTextField.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 20.03.2024.
//

import Foundation
import SwiftUI

struct TitleTextField: View {
    @Binding var title: String
    @FocusState var isFocused: Bool

    var body: some View {
        ZStack {
            TextField("Location name", text: $title)
                .focused($isFocused)

                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()

                        Button("Done") {
                            isFocused = false
                        }
                    }
                }

                .padding()
                .tint(.secondary)
                .background(RoundedRectangle(cornerRadius: 25, style: .continuous)

                    .foregroundStyle(.thinMaterial))
        }
    }
}
