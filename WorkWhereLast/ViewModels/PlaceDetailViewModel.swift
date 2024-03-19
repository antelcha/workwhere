//
//  PlaceDetailViewModel.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Foundation

@MainActor
class PlaceDetailViewModel: ObservableObject {
    @Published var model: PlacePosts
    @Published var user: UserModel?
    let firestoreManager = FirestoreManager.shared

    init(model: PlacePosts) {
        self.model = model
        Task {
            user =  try await firestoreManager.getUserById(id: model.userId)
        }
    }
}
