//
//  GalleryScreen.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI

struct GalleryScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("Gallery")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                Text("Your travel photos will appear here")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
                Spacer()
            }
            .navigationTitle("Gallery")
        }
    }
}

#Preview {
    GalleryScreen()
}
