//
//  FirestoreManager.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Firebase
import FirebaseStorage
import Foundation

struct AddPostModel: Identifiable {
    let id: String
    let userId: String
    let placeTitle: String
    let placeDescription: String
    let location: LocationModel
    let data: Data
    let userName: String
}

@MainActor
public class FirestoreManager {
    static let shared = FirestoreManager()

    // Reference to Firestore
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()

    private init() {}

    func addPost(_ placePost: AddPostModel) async throws {
        var UUIDArr: [String] = []
        var photoLinks: String = ""

        print("🔥")
        let UUID = UUID().uuidString
        let path = "images/\(UUID).jpg"
        UUIDArr.append(path)
        let fileRef = storageRef.child(path)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        // Upload image data to Firebase Storage
        let uploadTask = fileRef.putData(placePost.data, metadata: metadata)

        uploadTask.observe(.success) { _ in
            Task {
                let downloadURL = try await fileRef.downloadURL()
                photoLinks.append(downloadURL.absoluteString)

                let locationData: [String: Any] = [
                    "id": placePost.location.id,
                    "latitude": placePost.location.latitude,
                    "longitude": placePost.location.longitute,
                    "title": placePost.location.title,
                    "city": placePost.location.city,
                    "district": placePost.location.district,
                ]

                let data: [String: Any] = [
                    "id": placePost.id,
                    "imageUrl": photoLinks,
                    "placeDescription": placePost.placeDescription,
                    "location": locationData,
                    "placeTitle": placePost.placeTitle,
                    "userId": placePost.userId,
                    "userName": placePost.userName,
                ]

                print(data)
                try await self.db.collection("post").addDocument(data: data)

                let userQuerySnapshot = try await self.db.collection("user").whereField("id", isEqualTo: placePost.userId).getDocuments()

                if let doc = userQuerySnapshot.documents.first {
                    do {
                        let userDocumentRef = self.db.collection("user").document(doc.documentID)

                        // Fetch the user document
                        let userDocument = try await userDocumentRef.getDocument()

                        if userDocument.exists {
                            var userPostsArray = userDocument.data()?["posts"] as? [String] ?? []
                            userPostsArray.append(placePost.id)

                            // Update the 'posts' field in the user document
                            try await userDocumentRef.updateData(["posts": userPostsArray])

                            print("User document successfully updated with the new postId.")
                        } else {
                            print("User document does not exist")
                        }
                    } catch {
                        print("Error updating user document: \(error)")
                    }
                }
            }
        }
    }

    func getAllPosts() async throws -> [PlacePosts] {
        var postArr: [PlacePosts] = []

        let snapshot = try await db.collection("post").getDocuments()

        for doc in snapshot.documents {
            let locationData = doc["location"] as! [String: Any]

            let post = PlacePosts(
                id: doc["id"] as! String,
                userId: doc["userId"] as! String,
                placeTitle: doc["placeTitle"] as! String,
                placeDescription: doc["placeDescription"] as! String,
                location: LocationModel(
                    id: locationData["id"] as! String,
                    latitude: locationData["latitude"] as! Double,
                    longitute: locationData["longitude"] as! Double,
                    title: locationData["title"] as! String,
                    city: locationData["city"] as! String,
                    district: locationData["district"] as! String
                ),
                imageURL: doc["imageUrl"] as! String, userName: doc["userName"] as! String
            )
            postArr.append(post)
        }

        return postArr
    }

    func getPostById(wantedID: String) async throws -> PlacePosts? {
        let snapshot = try await db.collection("post").whereField("id", isEqualTo: wantedID).getDocuments()

        guard !snapshot.isEmpty, let doc = snapshot.documents.first else {
            return nil
        }

        let locationData = doc["location"] as! [String: Any]
        let post = PlacePosts(
            id: doc["id"] as! String,
            userId: doc["userId"] as! String,
            placeTitle: doc["placeTitle"] as! String,
            placeDescription: doc["placeDescription"] as! String,
            location: LocationModel(
                id: locationData["id"] as! String,
                latitude: locationData["latitude"] as! Double,
                longitute: locationData["longitude"] as! Double,
                title: locationData["title"] as! String,
                city: locationData["city"] as! String,
                district: locationData["district"] as! String
            ),
            imageURL: doc["imageUrl"] as! String, userName: doc["userName"] as! String
        )

        return post
    }

    func getUserById(id: String) async throws -> UserModel? {
        //        if let cachedUser = userCache[id] {
        //                    return cachedUser
        //                }
        //
        //
        let snapshot = try await db.collection("user").whereField("id", isEqualTo: id).getDocuments()

        guard let doc = snapshot.documents.first else {
            print("Kullanıcı bulunamadı")
            return nil
        }

        let userModel = UserModel(
            id: doc["id"] as! String,
            email: doc["email"] as! String,

            name: doc["name"] as! String,
            posts: doc["posts"] as! [String]
        )

        return userModel
        //    }

        func uploadImageData(_ imageData: Data) async throws -> String? {
            // Generate a unique ID for the image
            let uuid = UUID().uuidString
            let path = "images/\(uuid).jpg"
            let fileRef = storageRef.child(path)

            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            // Use an async continuation to manage the asynchronous flow
            return try await withCheckedThrowingContinuation { continuation in
                // Upload image data to Firestore Storage
                let uploadTask = fileRef.putData(imageData, metadata: metadata) { _, error in
                    // Handle the completion of the upload task
                    if let error = error {
                        // If there's an error, resume the continuation with the error
                        continuation.resume(throwing: error)
                    } else {
                        // If successful, get the download URL and resume the continuation with the URL
                        fileRef.downloadURL { url, error in
                            if let error = error {
                                // If there's an error, resume the continuation with the error
                                continuation.resume(throwing: error)
                            } else if let url = url {
                                // If successful, resume the continuation with the download URL
                                continuation.resume(returning: url.absoluteString)
                            } else {
                                // In case of unexpected behavior, resume the continuation with an appropriate error
                                let error = NSError(domain: "FirestoreService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])
                                continuation.resume(throwing: error)
                            }
                        }
                    }
                }
            }
        } // Get download URL
    }

    // Return the download URL as a string

    func deletePostById(id: String) async throws {
        let post = try await getPostById(wantedID: id)
        guard let userId = AuthManager.shared.currentUser.userId else { return }
        if post != nil {
            if post!.imageURL.isEmpty {
                print("images are empty")
            } else {
                db.collection("post").whereField("id", isEqualTo: id).getDocuments { snapshot, error in

                    if let a = error {
                        print(a.localizedDescription)
                    } else {
                        let path = "images/\(post!.imageURL).jpg"
                        let fileRef = self.storageRef.child(path)
                        fileRef.delete { error in
                            if error != nil {
                                print("imagedeleted")
                            }
                        }

                        snapshot?.documents.first?.reference.delete()
                    }
                }

                // Get reference to user document
                let userDocumentRef = db.collection("users").document(userId)

                // Fetch user document
                userDocumentRef.getDocument { userDocument, error in
                    if let error = error {
                        print("Error fetching user document: \(error.localizedDescription)")
                        return
                    }

                    // Check if user document exists
                    guard let userDocument = userDocument else {
                        print("User document does not exist.")
                        return
                    }

                    // Remove post ID from user's posts list
                    var userPostsArray = userDocument.data()?["posts"] as? [String] ?? []
                    if let index = userPostsArray.firstIndex(of: id) {
                        userPostsArray.remove(at: index)

                        // Update user document with updated posts list
                        userDocumentRef.updateData(["posts": userPostsArray]) { error in
                            if let error = error {
                                print("Error updating user document: \(error.localizedDescription)")
                            } else {
                                print("User document successfully updated with removed post ID.")
                            }
                        }
                    }
                }
            }
        }
    }
}

extension FirestoreManager {
    func createUser(_ user: UserModel) async throws {
        // Convert UserModel to Firestore data format
        let userData: [String: Any] = [
            "id": user.id,
            "email": user.email,
            "name": user.name,
            "posts": user.posts,
        ]

        // Add the user data to the Firestore 'user' collection
        try await db.collection("user").document(user.id).setData(userData)
    }

    func updateName(newName: String) async throws {
        guard let userId = AuthManager.shared.currentUser.userId else { return }

        do {
            // Query Firestore for the user document using the provided userId
            let userQuerySnapshot = try await db.collection("user").whereField("id", isEqualTo: userId).getDocuments()

            // Check if the query returned any documents
            guard let doc = userQuerySnapshot.documents.first else {
                print("User document not found for ID: \(userId)")
                return
            }

            // Get the ID of the user document
            let userDocumentId = doc.documentID

            // Reference to the user document in Firestore using the document ID
            let userDocumentRef = db.collection("user").document(userDocumentId)

            // Update the 'name' field in the user document
            try await userDocumentRef.updateData(["name": newName])

            print("User name successfully updated.")
        } catch {
            print("Error updating user name: \(error.localizedDescription)")
            throw error
        }
    }
}
