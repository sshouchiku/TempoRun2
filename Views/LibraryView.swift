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
                        spacing: 20
                    ) {

                        VStack(
                            alignment:
                                .leading,
                            spacing: 4
                        ) {

                            Text("ライブラリ")
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
                                "\(favoritesManager.favorites.count) お気に入り曲"
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }


                        if favoritesManager
                            .favorites
                            .isEmpty {

                            VStack(
                                spacing: 16
                            ) {

                                Image(
                                    systemName:
                                        "star"
                                )
                                .font(
                                    .system(
                                        size: 44
                                    )
                                )
                                .foregroundStyle(
                                    MelonomeTheme
                                        .accent
                                )

                                Text(
                                    "お気に入りはまだありません"
                                )
                                .font(.title3)
                                .fontWeight(.bold)

                                Text(
                                    "検索で気になる曲に☆を付けるとここに保存されます。"
                                )
                                .font(.subheadline)
                                .foregroundStyle(
                                    .secondary
                                )
                                .multilineTextAlignment(
                                    .center
                                )
                            }
                            .frame(
                                maxWidth:
                                    .infinity
                            )
                            .padding(
                                .top,
                                100
                            )

                        } else {

                            LazyVStack(
                                spacing: 10
                            ) {

                                ForEach(
                                    favoritesManager
                                        .favorites
                                ) { video in

                                    libraryRow(
                                        video
                                    )
                                }
                            }
                        }
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


    private func libraryRow(
        _ video:
            YouTubeVideo
    ) -> some View {

        HStack(
            spacing: 12
        ) {

            Button {

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
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(
            MelonomeTheme.card
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
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
