//
//  MainMenuView.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Foundation
import SwiftUI

struct MainMenuView: View {
    @StateObject var viewModel = MainMenuViewModel()
    @State private var showSignIn = false

    var body: some View {
        NavigationView {
            ScrollView {
                
                if (viewModel.places.count == 0) {
                    Text("No avaliable places yet.")
                }
                
                ForEach(viewModel.places, id: \.id) { model in

                    NavigationLink(destination:

                        NavigationLazyView(
                            PlaceDetailView(model: model)
                        )
                    ) {
                        PlaceCardView(model: model)

                    }.buttonStyle(PlainButtonStyle())
                }.id(UUID())
                    .padding(.horizontal)

                Spacer()
            }
          
            .navigationTitle(Text("All places"))
            .sheet(isPresented: $showSignIn, content: {
                SignInView()
            })
            .task {
                
                await self.viewModel.fetchPosts()
                
            }
            
        }

        
    }
}
