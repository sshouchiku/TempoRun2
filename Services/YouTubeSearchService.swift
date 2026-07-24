import Foundation

struct YouTubeSearchResult {
    let videos: [YouTubeVideo]
    let nextPageToken: String?
}

final class YouTubeSearchService {

    enum SearchError: Error {
        case apiKeyMissing
        case invalidURL
        case invalidResponse
        case videoNotFound
    }

    // =====================================
    // APIキー取得
    // =====================================

    private func getAPIKey() throws -> String {

        guard let apiKey =
                Bundle.main.object(
                    forInfoDictionaryKey: "YOUTUBE_API_KEY"
                ) as? String,
              !apiKey.isEmpty,
              apiKey != "$(YOUTUBE_API_KEY)"
        else {
            throw SearchError.apiKeyMissing
        }

        return apiKey
    }

    // =====================================
    // YouTube検索
    // =====================================

    func searchVideos(
        query: String,
        pageToken: String? = nil
    ) async throws -> YouTubeSearchResult {

        let apiKey = try getAPIKey()

        var components =
            URLComponents(
                string:
                    "https://www.googleapis.com/youtube/v3/search"
            )

        var queryItems: [URLQueryItem] = [

            URLQueryItem(
                name: "part",
                value: "snippet"
            ),

            URLQueryItem(
                name: "type",
                value: "video"
            ),

            URLQueryItem(
                name: "maxResults",
                value: "10"
            ),

            URLQueryItem(
                name: "q",
                value: query
            ),

            URLQueryItem(
                name: "key",
                value: apiKey
            )
        ]

        if let pageToken {

            queryItems.append(
                URLQueryItem(
                    name: "pageToken",
                    value: pageToken
                )
            )
        }

        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw SearchError.invalidURL
        }

        let (data, response) =
            try await URLSession.shared.data(
                from: url
            )

        guard let httpResponse =
                response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode
        else {
            throw SearchError.invalidResponse
        }

        let decoded =
            try JSONDecoder().decode(
                YouTubeSearchResponse.self,
                from: data
            )

        let videos =
            decoded.items.map {

                YouTubeVideo(
                    id: $0.id.videoId,
                    title: $0.snippet.title,
                    channelTitle:
                        $0.snippet.channelTitle,
                    thumbnailURL:
                        $0.snippet.thumbnails.medium.url
                )
            }

        return YouTubeSearchResult(
            videos: videos,
            nextPageToken:
                decoded.nextPageToken
        )
    }

    // =====================================
    // Video IDから動画情報を取得
    //
    // URL入力や初期動画で使用
    // =====================================

    func fetchVideo(
        videoID: String
    ) async throws -> YouTubeVideo {

        let apiKey = try getAPIKey()

        var components =
            URLComponents(
                string:
                    "https://www.googleapis.com/youtube/v3/videos"
            )

        components?.queryItems = [

            URLQueryItem(
                name: "part",
                value: "snippet"
            ),

            URLQueryItem(
                name: "id",
                value: videoID
            ),

            URLQueryItem(
                name: "key",
                value: apiKey
            )
        ]

        guard let url = components?.url else {
            throw SearchError.invalidURL
        }

        let (data, response) =
            try await URLSession.shared.data(
                from: url
            )

        guard let httpResponse =
                response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode
        else {
            throw SearchError.invalidResponse
        }

        let decoded =
            try JSONDecoder().decode(
                YouTubeVideoResponse.self,
                from: data
            )

        guard let item =
                decoded.items.first
        else {
            throw SearchError.videoNotFound
        }

        return YouTubeVideo(
            id: item.id,
            title: item.snippet.title,
            channelTitle:
                item.snippet.channelTitle,
            thumbnailURL:
                item.snippet.thumbnails.medium.url
        )
    }
}


// =====================================
// Search API Response
// =====================================

private struct YouTubeSearchResponse:
    Decodable {

    let items: [YouTubeSearchItem]
    let nextPageToken: String?
}

private struct YouTubeSearchItem:
    Decodable {

    let id: YouTubeSearchID
    let snippet: YouTubeSnippet
}

private struct YouTubeSearchID:
    Decodable {

    let videoId: String
}


// =====================================
// Videos API Response
// =====================================

private struct YouTubeVideoResponse:
    Decodable {

    let items: [YouTubeVideoItem]
}

private struct YouTubeVideoItem:
    Decodable {

    let id: String
    let snippet: YouTubeSnippet
}


// =====================================
// 共通
// =====================================

private struct YouTubeSnippet:
    Decodable {

    let title: String
    let channelTitle: String
    let thumbnails: YouTubeThumbnails
}

private struct YouTubeThumbnails:
    Decodable {

    let medium: YouTubeThumbnail
}

private struct YouTubeThumbnail:
    Decodable {

    let url: String
}
