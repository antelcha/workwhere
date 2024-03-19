//
//  DescriptionTextField.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 20.03.2024.
//

import Foundation
import SwiftUI


struct DescriptionTextField: View {
    @Binding var description: String
    @FocusState var isFocused: Bool
    @State private var isInfoOpened: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                TextField("Description", text: $description)

                    .focused($isFocused)
                    .padding(7)
                    .frame(height: 200)
                    .tint(.secondary)
                    .vibrancyEffect()

                    .scrollContentBackground(.hidden)

                    .cornerRadius(20)

                    .background(RoundedRectangle(cornerRadius: 25, style: .continuous)

                        .foregroundStyle(.thinMaterial))

            }.overlay(
                Image(systemName: "info")

                    .resizable()
                    .aspectRatio(contentMode: .fit)

                    .frame(height: 12)

                    .padding(10)

                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)

                    .background(Circle().foregroundStyle(.ultraThinMaterial))
                    .padding()
                    .onTapGesture(perform: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isInfoOpened.toggle()
                        }
                    })
                ,

                alignment: .bottomTrailing)
                .zIndex(3)

            if isInfoOpened {
                ZStack {
                    RoundedRectangle(cornerRadius: 25.0).frame(height: 200)

                        .zIndex(2)
                        .foregroundStyle(.thinMaterial)

                    Spacer().frame(height: 40)
                    Text("You can choose to write:\n-Quiet work areas\n-Internet speed\n-Plenty of sockets\n-Cleanliness of restrooms\n-Employee attitude\n-Music volume\n")
                        .font(.caption)
                        .vibrancyEffect()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .zIndex(4)
                        .offset(CGSize(width: 0, height: 20))
                }
                .frame(height: 200)
                .offset(CGSize(width: 0, height: -45))
                .transition(.opacity)
            }
        }
    }
}

