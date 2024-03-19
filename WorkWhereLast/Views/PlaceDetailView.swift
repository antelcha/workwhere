//
//  PlaceDetailView.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Foundation
import SwiftUI



struct PlaceDetailView: View {
    @ObservedObject var vm: PlaceDetailViewModel
    @State private var scrollPos: CGFloat?
    @State private var activeBlock = "first"

    init(model: PlacePosts) {
        _vm = ObservedObject(wrappedValue: PlaceDetailViewModel(model: model))
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    AsyncImage(url: URL(string: vm.model.imageURL)) { image in
                        image.image?
                            .resizable()
                            .frame(height: 250)
                            .scaledToFit()
                    }

                    .frame(height: 250)

                    .clipShape(RoundedRectangle(cornerRadius: 25))

                    HStack {
                        Text(vm.model.placeTitle)
                            .font(.title)
                            .bold()

                        Spacer()
                    }

                    HStack {
                        Image(systemName: "location.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20)
                        Text(vm.model.location.city).font(.caption).foregroundStyle(.secondary)
                        Spacer()
                    }

                    Spacer().frame(height: 40)

                    Text("Description")
                        .font(.title3)
                        .bold()

                    Text(vm.model.placeDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    NavigationLink(destination: {
                        AnotherUserProfileView(userId: vm.model.userId)
                        
                    }, label: {
                        HStack {
                            HStack {
                                Text(vm.model.userName)
                                    .bold()

                                    .font(.footnote)
//                                    .vibrancyEffect()
                            }
                            .padding(5)

                            .background(RoundedRectangle(cornerRadius: 20, style: .continuous)

                                .foregroundStyle(.ultraThinMaterial)
                            )

                            Spacer()
                        }
                    })
                }

                .padding()
            }

            VStack {
                Spacer()
                Link(destination: URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(vm.model.location.latitude),\(vm.model.location.longitute)")!) {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.forward.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16)
                        Text("Get Directions")
                    }
//                    .vibrancyEffect()
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 30, style: .continuous).foregroundStyle(.thinMaterial))
                }
                Spacer().frame(height: 30)
            }
        }
    }
}
