//
//  SettingsScreen.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("Settings")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                Text("App settings will appear here")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
                Spacer()
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsScreen()
}
