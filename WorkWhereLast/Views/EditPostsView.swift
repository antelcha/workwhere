//
//  EditPostsView.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 20.03.2024.
//

import Foundation
import SwiftUI

// EditPostsViewModel.swift
import Foundation

@MainActor
class EditPostsViewModel: ObservableObject {
    @Published var postItems: [PlacePosts] = []
    let firestoreManager = FirestoreManager.shared
    let authManager = AuthManager.shared

    func fetchUserPosts() async {
        var list = [PlacePosts]()
        guard let userId = authManager.currentUser.userId else { return }
        guard let user = try? await firestoreManager.getUserById(id: userId) else { return }
        for i in user.posts {
            guard let post = try? await firestoreManager.getPostById(wantedID: i) else { continue }
            list.append(post)
        }
        postItems = list
    }

    func deletePost(postId: String) async {
        try? await firestoreManager.deletePostById(id: postId)
        await fetchUserPosts()
    }
}

import SwiftUI

struct EditPostsView: View {
    @ObservedObject var viewModel = EditPostsViewModel()
    @State private var showAlert = false
    @State private var postIdToDelete = ""

    var body: some View {
        NavigationView {
            List(viewModel.postItems) { post in
                HStack {
                    VStack(alignment: .leading) {
                        Text(post.placeTitle)
                        Text(post.placeDescription)
                    }
                    Spacer()
                    Button(action: {
                        // Confirm deletion
                        showAlert = true
                        postIdToDelete = post.id
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                
                .padding(.vertical, 8)
            }
            .navigationBarTitle("Edit Posts")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        // Call delete function in ViewModel
                        Task { await viewModel.deletePost(postId: postIdToDelete) }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .task {
            await viewModel.fetchUserPosts()
        }
    }
}
