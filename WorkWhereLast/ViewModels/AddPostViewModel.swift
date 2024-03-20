//
//  AddPostViewModel.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 20.03.2024.
//

import Foundation

import Foundation
import PhotosUI
import SwiftUI

@MainActor
class AddPostViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var selectedItems: PhotosPickerItem?
    @Published var selectedImages: UIImage?
    @Published var location: LocationModel? = nil
    @Published var isGettingLocation: Bool = false
    @Published  var isSharingPost: Bool = false
    @Published var isSelectingLocation: Bool = false
    @Published var toast: Toast? = nil

    

    
    let firestoreManager = FirestoreManager.shared
    let authManager = AuthManager.shared

    init() {}
   
    
    
    func sharePost() async {
        
            isSharingPost = true
        
        guard location != nil else {
            
            self.isSharingPost = false
            _toast = Published(wrappedValue: Toast(style: .warning, title: "Error", message: "Location can not be empty"))
             
            return
        }
        
        guard title != "" else {
            self.isSharingPost = false
            _toast = Published(wrappedValue: Toast(style: .warning, title: "Error", message: "Title can not be empty"))
            
            
            return
        }
        
        guard description != "" else {
            self.isSharingPost = false
            _toast = Published(wrappedValue: Toast(style: .warning, title: "Error", message: "Description can not be empty"))
            
            
            return
        }
        
        guard selectedImages != nil else {
            self.isSharingPost = false
            _toast = Published(wrappedValue: Toast(style: .warning, title: "Error", message: "Image can not be empty."))
            
             
            return
        }
        guard let userid = authManager.currentUser.userId else {return}
        
        let post = AddPostModel(id: UUID().uuidString, userId: userid , placeTitle: title, placeDescription: description, location: location!, data: selectedImages?.jpegData(compressionQuality: 0.01) ?? Data(), userName: authManager.currentUser.profile?.displayName ?? "")
        
       
        do {
            try await firestoreManager.addPost(post)
        } catch {
            print(error)
        }
        
        isSharingPost = false
        _toast = Published(wrappedValue: Toast(style: .success, title: "Congrats!", message: "You shared a post successfully."))
        title = ""
        location = nil
        description = ""
        selectedItems = nil
        
    }
    
    

    
}
