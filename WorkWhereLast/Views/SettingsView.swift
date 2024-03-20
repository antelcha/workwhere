//
//  SettingsView.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 20.03.2024.
//

import Foundation

import PhotosUI
import SwiftUI



struct SettingsView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var vm: SettingsViewModel  = SettingsViewModel()
    @State private var showingConfirmation1 = false
    @State private var showingConfirmation2 = false

   

    var body: some View {
        ScrollView {
            VStack {
                Text(vm.model?.name ?? "")
                    .font(.title3)
                    .bold()
            }
            List {
                Section(header: Text("Support for you")) {
                    Link(destination: URL(string: "https://github.com/antelcha/WorkWhere_AppPolicy")!) {
                        Text("Terms and Conditions")
                    }
                    Link(destination: URL(string: "https://github.com/antelcha/WorkWhere_AppPolicy")!) {
                        Text("Privacy Policy")
                    }
                }
                Section(header: Text("Account")) {
                    
                    
                    
                    
                    NavigationLink {
                        ChangeNameView()
                    } label: {
                        Text("Change name")
                    }
                    
                    
                    NavigationLink {
                        EditPostsView()
                    } label: {
                        Text("Edit posts")
                    }
                    
                    

                    
                    
                    Button(action: {
                        showingConfirmation1 = true // Show the confirmation dialog
                    }, label: {
                        Text("Log out")
                    })
                    .confirmationDialog("Are you sure you want to log out?",
                                        isPresented: $showingConfirmation1,
                                        titleVisibility: .visible) {
                        Button("Log out") { Task {await vm.logOut()} }
                    }

                    Button(action: {
                        showingConfirmation2 = true // Show the confirmation dialog
                    }, label: {
                        Text("Delete account")
                    })
                    .confirmationDialog("Are you sure you want to delete your account? This action is irreversible.",
                                        isPresented: $showingConfirmation2,
                                        titleVisibility: .visible) {
                        Button("Delete Account", role: .destructive) { Task {await vm.deleteAccount() }}
                    }

                   
                }
            }
            .scrollContentBackground(.hidden)
            
            .frame(height: 600)
        }
        .task {
            await vm.getUser()
        }
        .navigationTitle("Settings")
    }
}

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var model: UserModel?
    
    let authManager = AuthManager.shared
    let firestoreManager = FirestoreManager.shared
    let userId: String

    @Published var name: String = ""
    @Published var imageData: Data? // Store image data

    init() {
        self.userId = authManager.currentUser.userId!
        
        

        // Initialize properties from the model
        name = model?.name ?? "Name"
    }

    func getUser() async {
        model = try? await firestoreManager.getUserById(id: userId)
    }

    func logOut() {
        try? authManager.signOut()
    }

    func saveChanges() {
        // Update your model with new values

        // ... (Save image data if changed)

        // Update the user data in the database
    }

    func deleteAccount() async {
        for i in 0 ..< (model?.posts.count ?? 0) {
            guard let id = model?.posts[i] else { return }
            
            try? await firestoreManager.deletePostById(id: id)
        }
        try? await authManager.deleteAuthentication()
    }
}

struct ChangePasswordView: View {
    @EnvironmentObject var vm: SettingsViewModel
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    // Add state variables for feedback/error messages as needed

    var body: some View {
        VStack {
            List {
                SecureField("Current Password", text: $currentPassword)
                SecureField("New Password", text: $newPassword)
                SecureField("Confirm New Password", text: $confirmPassword)
                Button(action: {
                }, label: {
                    Text("Save Changes")
                })
            }
        }

        .navigationTitle("Change Password")
    }
}
