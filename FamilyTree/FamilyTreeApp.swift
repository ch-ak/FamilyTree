//
//  FamilyTreeApp.swift
//  FamilyTree
//
//  Created by Chakri Kotcherlakota on 12/4/25.
//

import SwiftUI

@main
struct FamilyTreeApp: App {
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView(isActive: $showSplash)
            } else {
                ContentView()
            }
        }
    }
}
