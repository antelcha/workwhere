//
//  SnackbarView.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Foundation
import SwiftUI
import SwiftUIVisualEffects

struct SnackbarView: View {
    let snackbarContent: SnackbarModel

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: snackbarContent.place?.imageURL ?? "")) { image in
                image.image?
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                   
                    .clipped()
                    .cornerRadius(20)
            }
            .frame(width: 100, height: 100)
            
            
            VStack(alignment: .leading) {
                Text(snackbarContent.place?.placeTitle ?? "")
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .bold()
                
                Text(snackbarContent.place?.placeDescription ?? "")
                    .multilineTextAlignment(.leading)
                .font(.subheadline)
                .vibrancyEffect()
                
            }
            
            .frame(height: 100)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 25, style: .continuous).foregroundStyle(.thinMaterial))
        
        .transition(.move(edge: .bottom))
        .cornerRadius(10)
    }
}
