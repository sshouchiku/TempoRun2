import Foundation

struct YouTubeVideo: Identifiable, Codable, Hashable {

    let id: String
    let title: String
    let channelTitle: String
    let thumbnailURL: String
}
