//
//  PhotoEntity.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import Foundation
import SwiftData

@Model
final class PhotoEntity {
    @Attribute(.unique) var id: UUID
    var uri: String
    var stateCode: String
    var stateName: String
    var cityName: String
    var latitude: Double
    var longitude: Double
    var capturedDate: Date
    var addedDate: Date
    var thumbnailUri: String

    @Relationship(deleteRule: .cascade, inverse: \JournalEntryEntity.photo)
    var journalEntry: JournalEntryEntity?

    init(
        id: UUID = UUID(),
        uri: String,
        stateCode: String,
        stateName: String,
        cityName: String,
        latitude: Double,
        longitude: Double,
        capturedDate: Date,
        addedDate: Date = Date(),
        thumbnailUri: String = ""
    ) {
        self.id = id
        self.uri = uri
        self.stateCode = stateCode
        self.stateName = stateName
        self.cityName = cityName
        self.latitude = latitude
        self.longitude = longitude
        self.capturedDate = capturedDate
        self.addedDate = addedDate
        self.thumbnailUri = thumbnailUri
    }
}
