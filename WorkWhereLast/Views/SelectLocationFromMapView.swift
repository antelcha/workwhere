//
//  SelectLocationFromMapView.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 20.03.2024.
//

import Foundation

import MapKit
import SwiftUI


extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.center == rhs.center
    }
    
    
}

struct SelectLocationView: View {
    @Binding var selectedLocation: LocationModel?
    @Environment(\.dismiss) private var dismiss
    @GestureState private var dragOffset: CGSize = .zero
    @State private var circleSize: CGFloat = 10
    @State private var regionChangeTimer: Timer?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 32.8597), // Default Center
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )

    var body: some View {
        ZStack(alignment: .center) {
            
            Map(coordinateRegion: $region, interactionModes: .all, annotationItems: selectedLocation != nil ? [selectedLocation!] : []) { location in
                MapMarker(coordinate: location.get2DCoordinate())
                   
                

            }.onChange(of: region) { _ in
                regionChangeTimer?.invalidate() // Invalidate any existing timer
                circleSize = 15

                regionChangeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                    withAnimation(.bouncy) {
                        circleSize = 10
                    }
                }
            }

            
            
           
            .ignoresSafeArea()
            
            VStack {
                Image(systemName: "circle")
                    
                    
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipped(antialiased: true)
                    .frame(width: dragOffset == .zero ? circleSize : 15.00)
                Image(systemName: "location.north.fill")
            }
            
        }.overlay(alignment: .topTrailing) { // Add an overlay
            Button(action: {
                selectedLocation = createLocationFromCoordinates(region.center)
                dismiss()
                
            }) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                     // Customize as needed
            }
            .padding()
            
            
        }
    }

    private func createLocationFromCoordinates(_ coordinates: CLLocationCoordinate2D) -> LocationModel {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)) { placemarks, _ in
            if let placemark = placemarks?.first {
                selectedLocation = LocationModel(
                    latitude: coordinates.latitude,
                    longitute: coordinates.longitude,
                    title: placemark.name ?? "Selected Location",
                    city: placemark.locality ?? "",
                    district: placemark.subLocality ?? ""
                )
            }
        }
        return LocationModel(latitude: coordinates.latitude, longitute: coordinates.longitude, title: "Loading Address...", city: "", district: "") // Temporary
    }

    private func getCurrentUserLocation() async -> CLLocation? {
        // ... Replace with your actual location fetch mechanism
        return CLLocation(latitude: 39.9042, longitude: 32.8597)
    }
}

