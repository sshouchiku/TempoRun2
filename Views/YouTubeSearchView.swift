import SwiftUI

struct YouTubeSearchView: View {

    @Binding
    var selectedVideo: YouTubeVideo?

    @ObservedObject
    var favoritesManager:
        FavoritesManager

    @State
    private var searchText: String = ""

    @State
    private var searchResults:
        [YouTubeVideo] = []

    @State
    private var isSearching: Bool = false

    @State
    private var isLoadingMore: Bool = false

    @State
    private var errorMessage: String?

    @State
    private var nextPageToken: String?

    // 最後に検索した言葉
    @State
    private var currentQuery: String = ""

    private let searchService =
        YouTubeSearchService()


    var body: some View {

        VStack(spacing: 12) {

            // =====================================
            // 検索欄
            // =====================================

            HStack {

                TextField(
                    "曲名・アーティストを検索",
                    text: $searchText
                )
                .textFieldStyle(
                    .roundedBorder
                )
                .autocorrectionDisabled()

                Button("検索") {

                    search()
                }
                .buttonStyle(
                    .borderedProminent
                )
                .disabled(
                    isSearching
                )
            }


            // =====================================
            // 検索中
            // =====================================

            if isSearching {

                ProgressView(
                    "検索中..."
                )
                .padding(.vertical, 8)
            }


            // =====================================
            // エラー
            // =====================================

            if let errorMessage {

                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(
                        .red
                    )
            }


            // =====================================
            // 検索結果
            // =====================================

            if !searchResults.isEmpty {

                VStack(
                    alignment: .leading,
                    spacing: 10
                ) {

                    Text("検索結果")
                        .font(.headline)

                    ForEach(
                        searchResults
                    ) { video in

                        searchResultRow(
                            video
                        )
                    }


                    // =====================================
                    // もっと見る
                    // =====================================

                    if nextPageToken != nil {

                        Button {

                            loadMore()

                        } label: {

                            HStack {

                                Spacer()

                                if isLoadingMore {

                                    ProgressView()

                                } else {

                                    Image(
                                        systemName:
                                            "chevron.down"
                                    )

                                    Text(
                                        "もっと見る"
                                    )
                                    .fontWeight(
                                        .semibold
                                    )
                                }

                                Spacer()
                            }
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(
                            .bordered
                        )
                        .disabled(
                            isLoadingMore
                        )
                    }
                }
            }
        }
    }


    // =====================================
    // 検索結果1行
    // =====================================

    @ViewBuilder
    private func searchResultRow(
        _ video: YouTubeVideo
    ) -> some View {

        HStack(
            alignment: .center,
            spacing: 12
        ) {

            // -------------------------
            // 動画選択部分
            // -------------------------

            Button {

                selectedVideo =
                    video

            } label: {

                HStack(
                    alignment: .center,
                    spacing: 12
                ) {

                    AsyncImage(
                        url: URL(
                            string:
                                video.thumbnailURL
                        )
                    ) { image in

                        image
                            .resizable()
                            .scaledToFill()

                    } placeholder: {

                        Rectangle()
                            .fill(
                                Color.gray.opacity(
                                    0.2
                                )
                            )
                    }
                    .frame(
                        width: 110,
                        height: 62
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 8
                        )
                    )

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text(
                            video.title
                        )
                        .font(
                            .subheadline
                        )
                        .fontWeight(
                            .semibold
                        )
                        .foregroundStyle(
                            .primary
                        )
                        .lineLimit(2)
                        .multilineTextAlignment(
                            .leading
                        )

                        Text(
                            video.channelTitle
                        )
                        .font(.caption)
                        .foregroundStyle(
                            .secondary
                        )
                    }

                    Spacer()

                    if selectedVideo?.id
                        == video.id {

                        Image(
                            systemName:
                                "checkmark.circle.fill"
                        )
                        .font(.title2)
                        .foregroundStyle(
                            .blue
                        )
                    }
                }
            }
            .buttonStyle(.plain)


            // -------------------------
            // お気に入りボタン
            // -------------------------

            Button {

                favoritesManager
                    .toggleFavorite(
                        video
                    )

            } label: {

                Image(
                    systemName:
                        favoritesManager
                        .isFavorite(
                            video
                        )
                        ? "star.fill"
                        : "star"
                )
                .font(.title2)
                .foregroundStyle(
                    favoritesManager
                    .isFavorite(
                        video
                    )
                    ? .yellow
                    : .secondary
                )
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background {

            RoundedRectangle(
                cornerRadius: 12
            )
            .fill(
                selectedVideo?.id
                == video.id
                ? Color.blue.opacity(
                    0.10
                )
                : Color.gray.opacity(
                    0.06
                )
            )
        }
    }


    // =====================================
    // 新規検索
    // =====================================

    private func search() {

        let query =
            searchText
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )

        guard !query.isEmpty else {
            return
        }

        isSearching = true
        errorMessage = nil

        // 新しい検索なのでリセット
        currentQuery = query
        searchResults = []
        nextPageToken = nil

        Task {

            do {

                let result =
                    try await searchService
                        .searchVideos(
                            query: query
                        )

                await MainActor.run {

                    searchResults =
                        result.videos

                    nextPageToken =
                        result.nextPageToken

                    isSearching =
                        false
                }

            } catch {

                await MainActor.run {

                    errorMessage =
                        "検索に失敗しました: \(error.localizedDescription)"

                    isSearching =
                        false
                }
            }
        }
    }


    // =====================================
    // もっと見る
    // =====================================

    private func loadMore() {

        guard
            !currentQuery.isEmpty,
            let nextPageToken
        else {
            return
        }

        isLoadingMore = true
        errorMessage = nil

        Task {

            do {

                let result =
                    try await searchService
                        .searchVideos(
                            query:
                                currentQuery,
                            pageToken:
                                nextPageToken
                        )

                await MainActor.run {

                    // 今ある10件の下に追加
                    searchResults
                        .append(
                            contentsOf:
                                result.videos
                        )

                    self.nextPageToken =
                        result.nextPageToken

                    isLoadingMore =
                        false
                }

            } catch {

                await MainActor.run {

                    errorMessage =
                        "追加の検索結果を取得できませんでした"

                    isLoadingMore =
                        false
                }
            }
        }
    }
}
