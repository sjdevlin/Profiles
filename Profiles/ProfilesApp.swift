//
//  ProfilesApp.swift
//  Profiles
//
//  Created by Stephen Devlin on 13/09/2022.
//

import SwiftUI

@main

struct ProfilesApp: App {

    // this is to allow pop to root for iOS version under 16

    @ObservedObject var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}
