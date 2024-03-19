//
//  PlaceCardView.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 20.03.2024.
//

import Foundation
import SwiftUI


struct PlaceCardView: View {
    let model: PlacePosts
    

    init(model: PlacePosts) {
        self.model = model
        
    }

    var body: some View {
        ZStack {
            ZStack {
                AsyncImage(url: URL(string: model.imageURL)) { image in
                    image
                        .resizable()
                        .frame(height: 250)
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .frame(height: 250)
                        .foregroundStyle(.gray)
                }

                VStack(spacing: 0) {
                    HStack {
                        HStack {
                            Text(model.userName)
                                .bold()

                                .font(.footnote)
                                .vibrancyEffect()
                        }
                        .padding(5)

                        .background(RoundedRectangle(cornerRadius: 20, style: .continuous)

                            .foregroundStyle(.ultraThinMaterial)
                        )

                        Spacer()
                    }
                    .padding(8)

                    Spacer()

                    ZStack {
                        Rectangle()
                            .frame(height: 80)

                            .foregroundStyle(.regularMaterial)

                        VStack(alignment: .leading) {
                            HStack(alignment: .center) {
                                Text(model.placeTitle)
                                    .font(.callout)

                                Spacer()
                                Text(model.location.district + "/" + model.location.city)
                                    .font(.caption)
                                    .bold()
                                    .vibrancyEffect()
                            }
                            Spacer().frame(height: 10)

                            Text(model.placeDescription)

                                .font(.caption2)
                                .lineLimit(2)

                                .vibrancyEffect()

                            Spacer()
                        }
                        .padding(10)
                        .frame(height: 80)
                    }
                }

                .frame(height: 250)
            }
        }

        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
