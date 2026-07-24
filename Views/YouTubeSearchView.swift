import SwiftUI

struct YouTubeSearchView: View {

    @Binding
    var selectedVideo:
        YouTubeVideo?

    @ObservedObject
    var favoritesManager:
        FavoritesManager

    @State
    private var searchText =
        ""

    @State
    private var searchResults:
        [YouTubeVideo] = []

    @State
    private var isSearching =
        false

    @State
    private var isLoadingMore =
        false

    @State
    private var errorMessage:
        String?

    @State
    private var nextPageToken:
        String?

    @State
    private var currentQuery =
        ""

    private let searchService =
        YouTubeSearchService()


    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            // MARK: Search Bar

            HStack(
                spacing: 10
            ) {

                Image(
                    systemName:
                        "magnifyingglass"
                )
                .foregroundStyle(
                    .secondary
                )

                TextField(
                    "曲名・アーティストを検索",
                    text: $searchText
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(
                    .never
                )
                .submitLabel(.search)
                .onSubmit {

                    search()
                }

                if !searchText.isEmpty {

                    Button {

                        searchText = ""

                    } label: {

                        Image(
                            systemName:
                                "xmark.circle.fill"
                        )
                        .foregroundStyle(
                            .secondary
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(14)
            .background(
                MelonomeTheme.card
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 16
                )
            )


            Button {

                search()

            } label: {

                HStack {

                    Spacer()

                    if isSearching {

                        ProgressView()
                            .tint(.black)

                    } else {

                        Image(
                            systemName:
                                "magnifyingglass"
                        )

                        Text("検索")
                            .fontWeight(.bold)
                    }

                    Spacer()
                }
                .padding(.vertical, 13)
            }
            .foregroundStyle(
                .black
            )
            .background(
                MelonomeTheme.accent
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 14
                )
            )
            .disabled(
                isSearching
            )


            if let errorMessage {

                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(
                        .red
                    )
            }


            if !searchResults.isEmpty {

                Text("検索結果")
                    .font(.title3)
                    .fontWeight(.bold)


                LazyVStack(
                    spacing: 10
                ) {

                    ForEach(
                        searchResults
                    ) { video in

                        resultRow(
                            video
                        )
                    }
                }


                if nextPageToken != nil {

                    Button {

                        loadMore()

                    } label: {

                        HStack {

                            Spacer()

                            if isLoadingMore {

                                ProgressView()

                            } else {

                                Text(
                                    "もっと見る"
                                )
                                .fontWeight(
                                    .semibold
                                )

                                Image(
                                    systemName:
                                        "chevron.down"
                                )
                            }

                            Spacer()
                        }
                        .padding(.vertical, 14)
                    }
                    .foregroundStyle(
                        MelonomeTheme.accent
                    )
                    .background(
                        MelonomeTheme.card
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 14
                        )
                    )
                    .disabled(
                        isLoadingMore
                    )
                }
            }
        }
    }


    private func resultRow(
        _ video:
            YouTubeVideo
    ) -> some View {

        HStack(
            spacing: 12
        ) {

            Button {

                selectedVideo =
                    video

            } label: {

                HStack(
                    spacing: 12
                ) {

                    AsyncImage(
                        url:
                            URL(
                                string:
                                    video
                                    .thumbnailURL
                            )
                    ) { image in

                        image
                            .resizable()
                            .scaledToFill()

                    } placeholder: {

                        Rectangle()
                            .fill(
                                MelonomeTheme
                                    .cardLight
                            )
                    }
                    .frame(
                        width: 105,
                        height: 62
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 10
                        )
                    )


                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text(video.title)
                            .font(
                                .subheadline
                            )
                            .fontWeight(
                                .semibold
                            )
                            .lineLimit(2)
                            .foregroundStyle(
                                .white
                            )
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
                }
            }
            .buttonStyle(.plain)


            Button {

                favoritesManager
                    .toggleFavorite(
                        video
                    )

            } label: {

                Image(
                    systemName:
                        favoritesManager
                        .isFavorite(video)
                        ? "star.fill"
                        : "star"
                )
                .font(.title3)
                .foregroundStyle(
                    favoritesManager
                        .isFavorite(video)
                    ? MelonomeTheme.accent
                    : .secondary
                )
                .frame(
                    width: 40,
                    height: 40
                )
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(
            selectedVideo?.id
                == video.id
            ? MelonomeTheme
                .accent
                .opacity(0.12)
            : MelonomeTheme.card
        )
        .overlay {

            if selectedVideo?.id
                == video.id {

                RoundedRectangle(
                    cornerRadius: 16
                )
                .stroke(
                    MelonomeTheme.accent,
                    lineWidth: 1
                )
            }
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }


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
                        "検索に失敗しました"

                    isSearching =
                        false
                }
            }
        }
    }


    private func loadMore() {

        guard
            !currentQuery.isEmpty,
            let nextPageToken
        else {

            return
        }

        isLoadingMore = true


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
