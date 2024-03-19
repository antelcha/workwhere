//
//  PlaceAnnotationView.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Foundation
import SwiftUI


struct PlaceAnnotationView: View {
    let annotation: PlaceAnnotation

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: annotation.place.imageURL)) { image in
                image.image?
                    .resizable()
                    
                    .frame(width: 40, height: 40)
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .clipped()
            }
        }
    }
}
