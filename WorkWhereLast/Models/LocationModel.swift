//
//  LocationModel.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Foundation


struct LocationModel: Identifiable, Equatable {
    static func == (lhs: LocationModel, rhs: LocationModel) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitute == rhs.longitute
}
    // Add Identifiable for use in Map annotations
    var id = UUID().uuidString// For Identifiable
    let latitude: CGFloat
    let longitute: CGFloat
    let title: String
    let city: String
    let district: String

    init(id: String = UUID().uuidString, latitude: CGFloat, longitute: CGFloat, title: String, city: String, district: String) {
        self.id = id
        self.latitude = latitude
        self.longitute = longitute
        self.title = title
        self.city = city
        self.district = district
    }

   
}
