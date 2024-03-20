//
//  MapViewModel.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Combine
import Foundation
import MapKit

@MainActor
class MapViewModel: ObservableObject {
    var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 32.8597), // Default Center
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)) // Will trigger map updates
    
    @Published var showSnackbar = false
    var snackbarContent: SnackbarModel? = nil

    @Published var places: [PlacePosts] = []
    private var cancellables: Set<AnyCancellable> = []

    let firestoreManager = FirestoreManager.shared

    func fetchPosts() async {
        
            if let get = try? await firestoreManager.getAllPosts() { self.places = get
            }
        
    }
    
 
    
    func changeSnackbarContent(content: SnackbarModel) {
        self.snackbarContent = content
    }
    
    func toggleSnackbar() {
        DispatchQueue.main.async {
            self.showSnackbar.toggle()
        }
    }
}
