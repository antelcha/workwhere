//
//  MapViewModel.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Foundation
import MapKit
import Combine


@MainActor
class MapViewModel: ObservableObject {
    var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 32.8597), // Default Center
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))// Will trigger map updates
    @Published var selectedAnnotation: PlaceAnnotation? = nil
    @Published var showSnackbar = false
    @Published var snackbarContent: SnackbarModel? = nil

    @Published var places: [PlacePosts] = []
    private var cancellables: Set<AnyCancellable> = []
    
    let firestoreManager = FirestoreManager.shared
    
    func fetchPosts() async {
        if let get = try? await firestoreManager.getAllPosts()

        {
            DispatchQueue.main.async {
                self.places = get
            }
        }
        
    }

    
       
        
        
        
    
}
