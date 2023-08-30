//
//  TheComposableArchitectureApp.swift
//  TheComposableArchitecture
//
//  Created by Bekzhan Talgat on 29.08.2023.
//

import SwiftUI

@main
struct TheComposableArchitectureApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(appState: .init())
        }
    }
}
