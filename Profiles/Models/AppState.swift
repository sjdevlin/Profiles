//
//  AppState.swift
//  Profiles
//
//  Created by Stephen Devlin on 09/10/2022.
//

import Foundation

// this object is only used to allow pop to root in the navigation stack
// in ios 16 - this is not needed - but under that it is

final class AppState : ObservableObject {
    @Published var rootViewId = UUID()
}
