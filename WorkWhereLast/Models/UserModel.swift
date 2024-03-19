//
//  UserModel.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Foundation

struct UserModel: Identifiable {
    let id: String
    let email: String
    let name: String
    let posts: [String]
    
    init(id: String, email: String, name: String, posts: [String]) {
        self.id = id
        self.email = email
        
        self.name = name
        self.posts = posts
    }
}
