import Foundation
import SwiftData

@Model
final class TrackItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var artist: String
    var filePath: String
    var bookmark: Data
    var duration: Double
    var order: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        filePath: String,
        bookmark: Data,
        duration: Double,
        order: Int,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.filePath = filePath
        self.bookmark = bookmark
        self.duration = duration
        self.order = order
        self.createdAt = createdAt
    }
}

extension TrackItem {
    var displayTitle: String {
        guard !artist.isEmpty else { return title }
        return "\(artist) - \(title)"
    }

    var durationText: String {
        guard duration > 0 else { return "--:--" }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? "--:--"
    }
}
