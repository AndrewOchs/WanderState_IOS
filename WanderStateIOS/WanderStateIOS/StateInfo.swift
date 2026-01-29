//
//  StateInfo.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import Foundation

struct StateInfo: Identifiable {
    let id: String  // State code (e.g., "PA")
    let name: String  // Full name (e.g., "Pennsylvania")
    let pathData: String  // SVG path data string
    var photoCount: Int = 0

    // For states with multiple paths (like Michigan's Upper Peninsula)
    let additionalPaths: [String]

    var stateCode: String { id }

    init(id: String, name: String, pathData: String, photoCount: Int = 0, additionalPaths: [String] = []) {
        self.id = id
        self.name = name
        self.pathData = pathData
        self.photoCount = photoCount
        self.additionalPaths = additionalPaths
    }
}
