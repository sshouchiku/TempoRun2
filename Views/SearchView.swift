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

                            Text("検索")
                                .font(
                                    .system(
                                        size: 34,
                                        weight:
                                            .black,
                                        design:
                                            .rounded
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

                                        selectedVideo =
                                            video

                                        if let video {

                                            currentVideoID =
                                                video.id
                                        }
                                    }
                                ),
                            favoritesManager:
                                favoritesManager
                        )
                    }
                    .padding(18)
                    .padding(
                        .bottom,
                        selectedVideo != nil
                        ? 90
                        : 20
                    )
                }


                if let video =
                    selectedVideo {

                    VStack {

                        Spacer()

                        miniPlayer(
                            video
                        )
                    }
                }
            }
            .toolbar(.hidden)
        }
    }


    private func miniPlayer(
        _ video:
            YouTubeVideo
    ) -> some View {

        Button {

            selectedTab =
                .home

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
                    width: 58,
                    height: 46
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 8
                    )
                )


                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {

                    Text(video.title)
                        .font(.subheadline)
                        .fontWeight(
                            .semibold
                        )
                        .lineLimit(1)

                    Text(
                        video.channelTitle
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                    .lineLimit(1)
                }

                Spacer()

                Image(
                    systemName:
                        "waveform"
                )
                .foregroundStyle(
                    MelonomeTheme.accent
                )

                Image(
                    systemName:
                        "chevron.up"
                )
                .foregroundStyle(
                    .secondary
                )
            }
            .padding(10)
            .background(
                .ultraThinMaterial
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 16
                )
            )
            .padding(
                .horizontal,
                12
            )
            .padding(
                .bottom,
                4
            )
        }
        .buttonStyle(.plain)
    }
}
