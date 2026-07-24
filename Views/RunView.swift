import SwiftUI

struct RunView: View {

    @Environment(
        \.dismiss
    )
    private var dismiss


    @ObservedObject
    var locationManager:
        LocationManager


    @Binding
    var selectedVideo:
        YouTubeVideo?

    @Binding
    var playbackRate:
        Double

    @Binding
    var targetSpeed:
        Double

    @Binding
    var runningMode:
        RunningMode


    let onNextTrack:
        () -> Void


    var body: some View {

        ZStack {

            MelonomeTheme
                .background
                .ignoresSafeArea()


            VStack(
                spacing: 26
            ) {

                // =====================================
                // 上部
                // =====================================

                HStack {

                    VStack(
                        alignment: .leading,
                        spacing: 2
                    ) {

                        Text(
                            "Melonome"
                        )
                        .font(
                            .title2
                        )
                        .fontWeight(
                            .black
                        )


                        Text(
                            "ランニング中"
                        )
                        .font(
                            .caption
                        )
                        .foregroundStyle(
                            MelonomeTheme
                                .accent
                        )
                    }


                    Spacer()


                    Image(
                        systemName:
                            "figure.run"
                    )
                    .font(
                        .title
                    )
                    .foregroundStyle(
                        MelonomeTheme
                            .accent
                    )
                }


                Spacer()


                // =====================================
                // 現在速度
                // =====================================

                VStack(
                    spacing: 4
                ) {

                    Text(
                        "現在の速度"
                    )
                    .font(
                        .headline
                    )
                    .foregroundStyle(
                        .secondary
                    )


                    HStack(
                        alignment:
                            .firstTextBaseline,
                        spacing: 8
                    ) {

                        Text(
                            String(
                                format:
                                    "%.1f",
                                locationManager
                                    .speed
                            )
                        )
                        .font(
                            .system(
                                size: 92,
                                weight: .black,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            .white
                        )


                        Text(
                            "km/h"
                        )
                        .font(
                            .title2
                        )
                        .foregroundStyle(
                            .secondary
                        )
                    }
                }


                // =====================================
                // 目標 / 再生速度
                // =====================================

                HStack(
                    spacing: 12
                ) {

                    runStatCard(
                        title:
                            "目標速度",
                        value:
                            String(
                                format:
                                    "%.1f",
                                targetSpeed
                            ),
                        unit:
                            "km/h"
                    )


                    runStatCard(
                        title:
                            "再生速度",
                        value:
                            String(
                                format:
                                    "%.2f",
                                playbackRate
                            ),
                        unit:
                            "x"
                    )
                }


                // =====================================
                // 曲
                // =====================================

                if let video =
                    selectedVideo {

                    HStack(
                        spacing: 14
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
                            width: 90,
                            height: 54
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 10
                            )
                        )


                        VStack(
                            alignment:
                                .leading,
                            spacing: 4
                        ) {

                            Text(
                                video.title
                            )
                            .font(
                                .headline
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
                    .padding(
                        14
                    )
                    .background(
                        MelonomeTheme
                            .card
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 18
                        )
                    )
                }


                // =====================================
                // 次へ
                // =====================================

                Button {

                    onNextTrack()

                } label: {

                    HStack(
                        spacing: 12
                    ) {

                        Image(
                            systemName:
                                "forward.end.fill"
                        )
                        .font(
                            .title2
                        )


                        Text(
                            "次の曲"
                        )
                        .font(
                            .title3
                        )
                        .fontWeight(
                            .bold
                        )
                    }
                    .frame(
                        maxWidth:
                            .infinity
                    )
                    .padding(
                        .vertical,
                        18
                    )
                    .foregroundStyle(
                        .black
                    )
                    .background(
                        MelonomeTheme
                            .accent
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 20
                        )
                    )
                }
                .buttonStyle(
                    .plain
                )


                Spacer()


                // =====================================
                // 終了
                // =====================================

                Button {

                    dismiss()

                } label: {

                    Text(
                        "ランニング画面を終了"
                    )
                    .fontWeight(
                        .semibold
                    )
                    .frame(
                        maxWidth:
                            .infinity
                    )
                    .padding(
                        .vertical,
                        14
                    )
                }
                .buttonStyle(
                    .bordered
                )
                .tint(
                    .secondary
                )
            }
            .padding(
                22
            )
        }
        .preferredColorScheme(
            .dark
        )
    }


    // =====================================
    // Stat Card
    // =====================================

    private func runStatCard(
        title: String,
        value: String,
        unit: String
    ) -> some View {

        VStack(
            spacing: 6
        ) {

            Text(
                title
            )
            .font(
                .caption
            )
            .foregroundStyle(
                .secondary
            )


            HStack(
                alignment:
                    .firstTextBaseline,
                spacing: 3
            ) {

                Text(
                    value
                )
                .font(
                    .system(
                        size: 30,
                        weight: .bold,
                        design: .rounded
                    )
                )


                Text(
                    unit
                )
                .font(
                    .caption
                )
                .foregroundStyle(
                    .secondary
                )
            }
        }
        .frame(
            maxWidth:
                .infinity
        )
        .padding(
            16
        )
        .background(
            MelonomeTheme
                .card
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
    }
}
