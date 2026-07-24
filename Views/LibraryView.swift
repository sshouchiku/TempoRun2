import SwiftUI

struct LibraryView: View {

    @Binding
    var selectedVideo:
        YouTubeVideo?

    @Binding
    var currentVideoID:
        String

    @ObservedObject
    var favoritesManager:
        FavoritesManager

    @ObservedObject
    var shuffleManager:
        ShuffleManager

    @ObservedObject
    var historyManager:
        HistoryManager

    @Binding
    var shouldAutoplay:
        Bool

    @Binding
    var selectedTab:
        AppTab


    var body: some View {

        NavigationStack {

            ZStack {

                MelonomeTheme
                    .background
                    .ignoresSafeArea()


                ScrollView {

                    VStack(
                        alignment: .leading,
                        spacing: 28
                    ) {

                        // =====================================
                        // ヘッダー
                        // =====================================

                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {

                            Text(
                                "ライブラリ"
                            )
                            .font(
                                .system(
                                    size: 34,
                                    weight: .black,
                                    design: .rounded
                                )
                            )


                            Text(
                                "お気に入り \(favoritesManager.favorites.count)曲"
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }


                        // =====================================
                        // お気に入り
                        // =====================================

                        favoritesSection


                        // =====================================
                        // 最近再生した曲
                        // =====================================

                        recentSection
                    }
                    .padding(
                        18
                    )
                    .padding(
                        .bottom,
                        30
                    )
                }
            }
            .toolbar(
                .hidden
            )
        }
    }


    // =====================================
    // お気に入り
    // =====================================

    @ViewBuilder
    private var favoritesSection:
        some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            Text(
                "お気に入り"
            )
            .font(
                .title2
            )
            .fontWeight(
                .bold
            )


            if favoritesManager
                .favorites
                .isEmpty {

                Text(
                    "お気に入りはまだありません"
                )
                .foregroundStyle(
                    .secondary
                )
                .padding(
                    .vertical,
                    20
                )

            } else {

                Button {

                    startShuffle()

                } label: {

                    HStack {

                        Spacer()

                        Image(
                            systemName:
                                "shuffle"
                        )

                        Text(
                            shuffleManager
                                .isShuffleEnabled
                            ? "シャッフル再生中"
                            : "シャッフル再生"
                        )
                        .fontWeight(
                            .bold
                        )

                        Spacer()
                    }
                    .padding(
                        .vertical,
                        14
                    )
                }
                .foregroundStyle(
                    .black
                )
                .background(
                    MelonomeTheme
                        .accent
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16
                    )
                )


                LazyVStack(
                    spacing: 10
                ) {

                    ForEach(
                        favoritesManager
                            .favorites
                    ) { video in

                        libraryRow(
                            video,
                            showFavoriteButton:
                                true
                        )
                    }
                }
            }
        }
    }


    // =====================================
    // 最近再生
    // =====================================

    @ViewBuilder
    private var recentSection:
        some View {

        if !historyManager
            .recentVideos
            .isEmpty {

            VStack(
                alignment: .leading,
                spacing: 14
            ) {

                HStack {

                    Text(
                        "最近再生した曲"
                    )
                    .font(
                        .title2
                    )
                    .fontWeight(
                        .bold
                    )


                    Spacer()


                    Button(
                        "履歴を消去"
                    ) {

                        historyManager
                            .clear()
                    }
                    .font(
                        .caption
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }


                LazyVStack(
                    spacing: 10
                ) {

                    ForEach(
                        historyManager
                            .recentVideos
                    ) { video in

                        libraryRow(
                            video,
                            showFavoriteButton:
                                false
                        )
                    }
                }
            }
        }
    }


    // =====================================
    // 曲Row
    // =====================================

    private func libraryRow(
        _ video:
            YouTubeVideo,
        showFavoriteButton:
            Bool
    ) -> some View {

        HStack(
            spacing: 12
        ) {

            Button {

                shuffleManager
                    .stop()

                // 選択したら即再生

                shouldAutoplay =
                    true

                selectedVideo =
                    video

                currentVideoID =
                    video.id

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
                        width: 96,
                        height: 58
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

                        Text(
                            video.title
                        )
                        .font(
                            .subheadline
                        )
                        .fontWeight(
                            .semibold
                        )
                        .lineLimit(2)


                        Text(
                            video.channelTitle
                        )
                        .font(
                            .caption
                        )
                        .foregroundStyle(
                            .secondary
                        )
                    }


                    Spacer()
                }
            }
            .buttonStyle(
                .plain
            )


            if showFavoriteButton {

                Button {

                    favoritesManager
                        .toggleFavorite(
                            video
                        )

                } label: {

                    Image(
                        systemName:
                            "star.fill"
                    )
                    .foregroundStyle(
                        MelonomeTheme
                            .accent
                    )
                    .frame(
                        width: 42,
                        height: 42
                    )
                }
                .buttonStyle(
                    .plain
                )

            } else {

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
                    .foregroundStyle(
                        favoritesManager
                            .isFavorite(
                                video
                            )
                        ? MelonomeTheme
                            .accent
                        : .secondary
                    )
                    .frame(
                        width: 42,
                        height: 42
                    )
                }
                .buttonStyle(
                    .plain
                )
            }
        }
        .padding(
            10
        )
        .background(
            MelonomeTheme
                .card
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }


    // =====================================
    // シャッフル開始
    // =====================================

    private func startShuffle() {

        guard let video =
                shuffleManager
                    .startShuffle(
                        favorites:
                            favoritesManager
                                .favorites
                    )
        else {
            return
        }


        shouldAutoplay =
            true

        selectedVideo =
            video

        currentVideoID =
            video.id

        selectedTab =
            .home
    }
}
