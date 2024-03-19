//
//  AnotherUserProfileView.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 20.03.2024.
//

import SwiftUI


@MainActor
class AnotherUserProfileViewModel: ObservableObject {
    let firestoreManager = FirestoreManager.shared
    let userID: String
    
    @Published var user: UserModel?
    @Published var userPosts: [PlacePosts] = []
    
    init(userId: String) {
        self.userID = userId
        
    }
    
    
    func fetchUser() async {
        user = try? await firestoreManager.getUserById(id: userID)
    }
    
    func fetchPosts() async {
        print(user)
        
        var tempPosts: [PlacePosts] = []
        guard let user = user else {return}
        
        for i in 0..<user.posts.count {
            print(i)
            guard let post = try? await firestoreManager.getPostById(wantedID: user.posts[i]) else {continue}
            tempPosts.append(post)
            
        }
        
        self.userPosts = tempPosts
    }
    
    
}

struct AnotherUserProfileView: View {
    
    @ObservedObject var vm: AnotherUserProfileViewModel
    
    
    init(userId: String) {
        
        self._vm = ObservedObject(wrappedValue: AnotherUserProfileViewModel(userId: userId))

    }
    
    var body: some View {
        
            ScrollView {
                
                    VStack {
                        Spacer().frame(height: 100)
                       
                        HStack(alignment: .center) {
                            
                            
                            VStack(alignment: .leading) {
                                Text(vm.user?.name ?? "")
                                    .font(.title2)
                                    .bold()
                                HStack(spacing: 0) {
                                    Text("\(vm.userPosts.count)")
                                        .bold()
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                    Text(" places")
                                        .bold()
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                        }
                        
                        
                        ForEach(vm.userPosts, id: \.id) { model in

                            NavigationLink(destination:

                                NavigationLazyView(
                                    PlaceDetailView(model: model)
                                )
                            ) {
                                PlaceCardView(model: model)

                            }.buttonStyle(PlainButtonStyle())
                        }.id(UUID())
                        
                        
                    }
                    .padding()
                
                
            }
            
            .task {
                await vm.fetchUser()
                await vm.fetchPosts()
                
                
        }
        }
    }
