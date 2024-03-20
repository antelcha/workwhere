//
//  CreateProfileView.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 20.03.2024.
//

import SwiftUI
import UIKit

@MainActor
struct ChangeNameView: View {
    @Environment(\.dismiss) var dismiss
    let firestoreManager = FirestoreManager.shared
    let authManager = AuthManager.shared

    @State private var nameField = ""

    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            TextField("Enter your name", text: $nameField, prompt: Text("Choose your name"))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if nameField.isEmpty { return }

                Task {
                    try? await firestoreManager.updateName(newName: nameField)
                    dismiss()
                }

            }, label: {
                if isLoading { ProgressView() } else { Text("Continue") }

            })
            .buttonStyle(.borderedProminent)
            .padding()
        }

        .onAppear {
            DispatchQueue.main.async {
                nameField = authManager.currentUser.profile?.displayName ?? ""
            }
        }
        .padding()
    }
}
