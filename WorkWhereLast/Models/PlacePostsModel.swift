//
//  PlacePosts.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Foundation

struct PlacePosts: Identifiable {
    let id: String
    let userId: String
    let userName: String
    let placeTitle: String
    let placeDescription: String
    let location: LocationModel
    let imageURL: String

    init(id: String, userId: String, placeTitle: String, placeDescription: String, location: LocationModel, imageURL: String, userName: String) {
        self.id = id
        self.userId = userId
        self.placeTitle = placeTitle
        self.placeDescription = placeDescription
        self.location = location
        self.imageURL = imageURL
        self.userName = userName
    }
}
