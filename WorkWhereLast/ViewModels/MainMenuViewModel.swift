//
//  MainMenuViewModel.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Foundation

@MainActor
class MainMenuViewModel: ObservableObject {
    @Published var places: [PlacePosts] = [
       
    ]

    let firestoreManager = FirestoreManager.shared
    let authManager = AuthManager.shared

    init() {
    }

    func fetchPosts() async {
        print("aaa")
        guard let posts = try? await firestoreManager.getAllPosts() else {
            return
        }
        if posts.count == places.count { return }
        print(posts)
        
        Task {
            self.places = posts
        }
        objectWillChange.send()
        
    }

    func getDetailedModel(id: String) async -> PlacePosts? {
        let model = try? await firestoreManager.getPostById(wantedID: id)
        return model
    }
}
