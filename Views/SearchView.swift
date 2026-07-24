import SwiftUI

struct SearchView: View {

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
                        alignment:
                            .leading,
                        spacing: 22
                    ) {

                        VStack(
                            alignment:
                                .leading,
                            spacing: 4
                        ) {

                            Text(
                                "検索"
                            )
                            .font(
                                .system(
                                    size: 34,
                                    weight: .black,
                                    design: .rounded
                                )
                            )


                            Text(
                                "走りたい気分に合う曲を探そう。"
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }


                        YouTubeSearchView(
                            selectedVideo:
                                Binding(
                                    get: {

                                        selectedVideo

                                    },
                                    set: {
                                        video in

                                        guard let video
                                        else {

                                            return
                                        }


                                        // 個別選択なので
                                        // シャッフル停止

                                        shuffleManager
                                            .stop()


                                        // 自動再生しない

                                        shouldAutoplay =
                                            true


                                        selectedVideo =
                                            video

                                        currentVideoID =
                                            video.id
                                    }
                                ),
                            favoritesManager:
                                favoritesManager
                        )
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
}
