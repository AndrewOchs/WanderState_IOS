//
//  StatsScreen.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI

struct StatsScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("Stats")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                Text("Your travel statistics will appear here")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
                Spacer()
            }
            .navigationTitle("Stats")
        }
    }
}

#Preview {
    StatsScreen()
}
