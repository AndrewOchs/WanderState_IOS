//
//  MainTabView.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var navigationManager = NavigationManager.shared
    @State private var themeManager = ThemeManager.shared

    var body: some View {
        TabView(selection: $navigationManager.selectedTab) {
            MapScreen()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(0)

            GalleryScreen()
                .tabItem {
                    Label("Gallery", systemImage: "photo.on.rectangle")
                }
                .tag(1)

            StatsScreen()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(2)

            SettingsScreen()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(themeManager.primary)
    }
}

#Preview {
    MainTabView()
}
