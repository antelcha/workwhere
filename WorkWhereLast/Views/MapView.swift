//
//  MapView.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Foundation
import SwiftUI
import MapKit




struct MapView: View {
    @ObservedObject var viewModel: MapViewModel = MapViewModel()
    
    
    
    var body: some View {
        
            ZStack {
                VStack {
                    Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.places) { place in
                        MapAnnotation(coordinate: place.location.get2DCoordinate()) {
                            PlaceAnnotationView(annotation: PlaceAnnotation(place: place))
                                .onTapGesture {
                                    viewModel.snackbarContent = SnackbarModel(place: place)
                                    
                                    
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            viewModel.showSnackbar.toggle()
                                        }
                                    }
                                    
                                }
                        }
                    }.onTapGesture {
                        withAnimation(.spring) {
                            viewModel.showSnackbar = false
                        }
                    }
                    
                }
                .task {
                    await viewModel.fetchPosts()
                    
                }
                .overlay(alignment: .bottom) {
                    if viewModel.showSnackbar {
                        NavigationLink {
                            PlaceDetailView(model: viewModel.snackbarContent!.place!)
                        } label: {
                            SnackbarView(snackbarContent: viewModel.snackbarContent!).padding()
                        }
                        
                        
                    }
                }
                
                VStack {
                    Spacer().frame(height: 30)
                    Button(action: {
                        Task {
                            await viewModel.fetchPosts()
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16)
                            Text("Reload")
                            
                        }
                        .vibrancyEffect()
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 30, style: .continuous).foregroundStyle(.thinMaterial))
                        
                        
                    })
                    Spacer()
                }
            }
        }
}

