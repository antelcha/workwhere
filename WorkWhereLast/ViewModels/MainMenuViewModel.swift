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
        PlacePosts(id: "aaa", userId: "aaa", placeTitle: "Mustafa", placeDescription: "Yok", location: LocationModel(latitude: 0, longitute: 0, title: "aaa", city: "aaa", district: "aaaaa"), imageURL: "https://fastly.picsum.photos/id/198/300/200.jpg?hmac=tklm6CzIgRqZX66BjwFARM05cLtx4iUCSwzmz75qRzA", userName: "Mustafa Girign"),
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

        places = posts
    }

    func getDetailedModel(id: String) async -> PlacePosts? {
        let model = try? await firestoreManager.getPostById(wantedID: id)
        return model
    }
}
