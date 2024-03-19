//
//  NavigationLazyView.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 20.03.2024.
//

import Foundation
import SwiftUI

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}
