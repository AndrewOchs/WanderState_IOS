//
//  WanderStateIOSApp.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI
import SwiftData

@main
struct WanderStateIOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [PhotoEntity.self, JournalEntryEntity.self])
    }
}
