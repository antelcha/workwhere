//
//  WorkWhereLastApp.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Firebase
import SwiftUI

@main
struct WorkWhereLastApp: App {
    @ObservedObject var authManager: AuthManager

    init() {
        FirebaseApp.configure()
        authManager = AuthManager.shared
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                MainMenuView()
                    .tabItem {
                        VStack {
                            Image(systemName: "house")
                            Text("Places")
                        }
                    }
                NavigationView {
                    MapView()

                }.tabItem {
                    VStack {
                        Image(systemName: "map")
                        Text("All places")
                    }
                }

                if authManager.currentUser.userId != nil {
                    NavigationView {
                        AnotherUserProfileView(userId: authManager.currentUser.userId!)
                            .toolbar {
                                ToolbarItem {
                                    NavigationLink(destination: {
                                        SettingsView()
                                    }, label: {
                                        Image(systemName: "gearshape.fill")
                                    })
                                }
                            }

                    }.tabItem {
                        VStack {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                    }
                } else {
                    SignInView()
                        .tabItem {
                            VStack {
                                Image(systemName: "person.fill")
                                Text("Profile")
                            }
                        }
                }

                if authManager.currentUser.userId != nil {
                    NavigationView {
                        AddPostView()

                    }.tabItem {
                        VStack {
                            Image(systemName: "plus")
                            Text("Add Post")
                        }
                    }
                } else {
                    SignInView()
                        .tabItem {
                            VStack {
                                Image(systemName: "plus")
                                Text("Add Post")
                            }
                        }
                }

            }.preferredColorScheme(.light)
        }
    }
}
