import Foundation
import SwiftData

@MainActor
final class PlaylistStorageService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchTracks() throws -> [TrackItem] {
        let descriptor = FetchDescriptor<TrackItem>(sortBy: [SortDescriptor(\TrackItem.order)])
        return try context.fetch(descriptor)
    }

    func appendTrack(title: String, artist: String, url: URL, bookmark: Data, duration: Double) throws -> TrackItem {
        let nextOrder = try fetchTracks().count
        let item = TrackItem(
            title: title,
            artist: artist,
            filePath: url.path,
            bookmark: bookmark,
            duration: duration,
            order: nextOrder
        )
        context.insert(item)
        try context.save()
        return item
    }

    func remove(track: TrackItem) throws {
        context.delete(track)
        try normalizeOrder()
    }

    func normalizeOrder() throws {
        let tracks = try fetchTracks()
        for (index, track) in tracks.enumerated() {
            track.order = index
        }
        try context.save()
    }
}
