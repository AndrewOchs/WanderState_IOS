//
//  JournalEntryEntity.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import Foundation
import SwiftData

@Model
final class JournalEntryEntity {
    var id: UUID
    var photoId: UUID
    var entryText: String
    var createdDate: Date
    var updatedDate: Date

    var photo: PhotoEntity?

    init(
        id: UUID = UUID(),
        photoId: UUID,
        entryText: String,
        createdDate: Date = Date(),
        updatedDate: Date = Date(),
        photo: PhotoEntity? = nil
    ) {
        self.id = id
        self.photoId = photoId
        self.entryText = entryText
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.photo = photo
    }
}
