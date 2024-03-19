//
//  MainMenuView.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Foundation
import SwiftUI

struct MainMenuView: View {
    @ObservedObject var viewModel = MainMenuViewModel()
    @State private var showSignIn = false

    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(viewModel.places, id: \.id) { model in

                    NavigationLink(destination:

                        NavigationLazyView(
                            PlaceDetailView(model: model)
                        )
                    ) {
                        PlaceCardView(model: model)

                    }.buttonStyle(PlainButtonStyle())
                }.id(UUID())

                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle(Text("All places"))
            .sheet(isPresented: $showSignIn, content: {
                SignInView()
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if (viewModel.authManager.isSignedIn) {
                        NavigationLink {
                            AddPostView()
                        } label: {
                            Image(systemName: "plus")
                        }

                    }
                    else {
                        Button {
                            showSignIn = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    
                }
            }
        }

        .task {
            //            await viewModel.fetchPosts()
        }
    }
}
