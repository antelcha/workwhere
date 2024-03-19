//
//  LocationModel+Ext.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Foundation
import MapKit

extension LocationModel {
    func get2DCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitute)

    }
}
