import SwiftUI

struct HomeView: View {

    @ObservedObject
    var locationManager: LocationManager

    @ObservedObject
    var favoritesManager: FavoritesManager

    @Binding
    var selectedVideo: YouTubeVideo?

    @Binding
    var currentVideoID: String

    @Binding
    var playbackRate: Double

    @Binding
    var targetSpeed: Double

    @Binding
    var runningMode: RunningMode


    private let youtubeService =
        YouTubeSearchService()


    @State
    private var lastAppliedRate: Double = 0.6

    @State
    private var lastRateChangeTime:
        Date = .distantPast


    var body: some View {

        NavigationStack {

            ZStack {

                MelonomeTheme.background
                    .ignoresSafeArea()

                ScrollView {

                    VStack(
                        alignment: .leading,
                        spacing: 26
                    ) {

                        header

                        playerSection

                        runningSection

                        modeSection

                        favoritesSection
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 30)
                }
            }
            .toolbar(.hidden)
            .task {

                if selectedVideo == nil {

                    await loadDefaultVideo()
                }
            }
            .onChange(
                of: locationManager.speed
            ) { _, speed in

                updatePlaybackRate(
                    currentSpeed: speed
                )
            }
            .onChange(
                of: targetSpeed
            ) { _, _ in

                updatePlaybackRate(
                    currentSpeed:
                        locationManager.speed,
                    force: true
                )
            }
            .onChange(
                of: runningMode
            ) { _, _ in

                updatePlaybackRate(
                    currentSpeed:
                        locationManager.speed,
                    force: true
                )
            }
        }
    }


    // MARK: - Header

    private var header: some View {

        VStack(
            alignment: .leading,
            spacing: 2
        ) {

            Text("Melonome")
                .font(
                    .system(
                        size: 36,
                        weight: .black,
                        design: .rounded
                    )
                )
                .foregroundStyle(.white)

            Text("Music follows your pace.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }


    // MARK: - Player

    private var playerSection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            YouTubePlayerView(
                videoID: currentVideoID,
                playbackRate: $playbackRate
            )
            .id(currentVideoID)
            .aspectRatio(
                16 / 9,
                contentMode: .fit
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 22
                )
            )


            if let video = selectedVideo {

                HStack(
                    spacing: 14
                ) {

                    VStack(
                        alignment: .leading,
                        spacing: 5
                    ) {

                        Text(video.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .lineLimit(2)
                            .foregroundStyle(.white)

                        Text(video.channelTitle)
                            .font(.subheadline)
                            .foregroundStyle(
                                .secondary
                            )
                    }

                    Spacer()

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
                        .font(.title2)
                        .foregroundStyle(
                            favoritesManager
                                .isFavorite(video)
                            ? MelonomeTheme.accent
                            : .secondary
                        )
                        .frame(
                            width: 48,
                            height: 48
                        )
                        .background(
                            MelonomeTheme.card
                        )
                        .clipShape(
                            Circle()
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }


    // MARK: - Running

    private var runningSection: some View {

        VStack(
            spacing: 18
        ) {

            VStack(
                spacing: 2
            ) {

                Text("現在の速度")
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(1.5)
                    .foregroundStyle(
                        MelonomeTheme.accent
                    )

                HStack(
                    alignment: .firstTextBaseline,
                    spacing: 6
                ) {

                    Text(
                        String(
                            format: "%.1f",
                            locationManager.speed
                        )
                    )
                    .font(
                        .system(
                            size: 72,
                            weight: .black,
                            design: .rounded
                        )
                    )

                    Text("km/h")
                        .font(.headline)
                        .foregroundStyle(
                            .secondary
                        )
                }
            }


            HStack(
                spacing: 12
            ) {

                metricCard(
                    title: "目標速度",
                    value:
                        String(
                            format: "%.1f",
                            targetSpeed
                        ),
                    unit: "km/h",
                    icon: "scope"
                )

                metricCard(
                    title: "再生速度",
                    value:
                        String(
                            format: "%.2f",
                            playbackRate
                        ),
                    unit: "x",
                    icon:
                        playbackRate > 1
                        ? "bolt.fill"
                        : "waveform"
                )
            }


            VStack(
                spacing: 10
            ) {

                HStack {

                    Text("目標速度")
                        .fontWeight(
                            .semibold
                        )

                    Spacer()

                    Text(
                        String(
                            format:
                                "%.1f km/h",
                            targetSpeed
                        )
                    )
                    .foregroundStyle(
                        MelonomeTheme.accent
                    )
                    .fontWeight(.bold)
                }

                Slider(
                    value: $targetSpeed,
                    in: 5...20,
                    step: 0.5
                )
                .tint(
                    MelonomeTheme.accent
                )
            }
            .padding(18)
            .background(
                MelonomeTheme.card
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20
                )
            )
        }
    }


    // MARK: - Mode

    private var modeSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text("走行モード")
                .font(.title3)
                .fontWeight(.bold)


            Picker(
                "走行モード",
                selection: $runningMode
            ) {

                Text("ノーマル")
                    .tag(
                        RunningMode.normal
                    )

                Text("ブースト")
                    .tag(
                        RunningMode.boost
                    )
            }
            .pickerStyle(.segmented)


            HStack(
                spacing: 10
            ) {

                Image(
                    systemName:
                        runningMode == .boost
                        ? "bolt.fill"
                        : "metronome.fill"
                )
                .foregroundStyle(
                    MelonomeTheme.accent
                )

                Text(
                    runningMode.description
                )
                .font(.subheadline)
                .foregroundStyle(
                    .secondary
                )
            }
            .padding(
                .horizontal,
                4
            )
        }
    }


    // MARK: - Favorites

    @ViewBuilder
    private var favoritesSection:
        some View {

        if !favoritesManager
            .favorites
            .isEmpty {

            VStack(
                alignment: .leading,
                spacing: 14
            ) {

                Text("お気に入り")
                    .font(.title2)
                    .fontWeight(.bold)


                ScrollView(
                    .horizontal,
                    showsIndicators: false
                ) {

                    HStack(
                        spacing: 14
                    ) {

                        ForEach(
                            favoritesManager
                                .favorites
                                .prefix(8)
                        ) { video in

                            Button {

                                selectedVideo =
                                    video

                                currentVideoID =
                                    video.id

                            } label: {

                                VStack(
                                    alignment:
                                        .leading,
                                    spacing: 7
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
                                        width: 165,
                                        height: 95
                                    )
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius:
                                                14
                                        )
                                    )

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
                                    .foregroundStyle(
                                        .white
                                    )
                                    .frame(
                                        width: 165,
                                        alignment:
                                            .leading
                                    )

                                    Text(
                                        video
                                            .channelTitle
                                    )
                                    .font(.caption)
                                    .foregroundStyle(
                                        .secondary
                                    )
                                    .lineLimit(1)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }


    // MARK: - Metric Card

    private func metricCard(
        title: String,
        value: String,
        unit: String,
        icon: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                Image(
                    systemName: icon
                )
                .foregroundStyle(
                    MelonomeTheme.accent
                )

                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        .secondary
                    )
            }

            HStack(
                alignment: .firstTextBaseline,
                spacing: 4
            ) {

                Text(value)
                    .font(
                        .system(
                            size: 30,
                            weight: .bold,
                            design: .rounded
                        )
                    )

                Text(unit)
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(18)
        .background(
            MelonomeTheme.card
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )
    }


    // MARK: - Default Video

    @MainActor
    private func loadDefaultVideo()
        async {

        do {

            let video =
                try await youtubeService
                    .fetchVideo(
                        videoID:
                            currentVideoID
                    )

            selectedVideo =
                video

        } catch {

            print(
                "初期動画情報取得失敗:",
                error
            )
        }
    }


    // MARK: - Playback Logic

    private func updatePlaybackRate(
        currentSpeed: Double,
        force: Bool = false
    ) {

        let minimumRate = 0.6
        let originalMinimumRate = 0.4
        let speedRange = 5.0

        let minimumSpeed =
            targetSpeed - speedRange

        let calculatedRate: Double


        if currentSpeed >= targetSpeed {

            switch runningMode {

            case .normal:

                calculatedRate = 1.0

            case .boost:

                let excess =
                    currentSpeed
                    - targetSpeed

                let increase =
                    (
                        1.0
                        - originalMinimumRate
                    )
                    / speedRange

                calculatedRate =
                    1.0
                    + excess
                    * increase
            }

        } else if currentSpeed
                    <= minimumSpeed {

            calculatedRate =
                originalMinimumRate

        } else {

            let progress =
                (
                    currentSpeed
                    - minimumSpeed
                )
                / speedRange

            calculatedRate =
                originalMinimumRate
                + (
                    1.0
                    - originalMinimumRate
                )
                * progress
        }


        let maximumRate =
            runningMode == .boost
            ? 1.4
            : 1.0

        let limitedRate =
            min(
                max(
                    calculatedRate,
                    minimumRate
                ),
                maximumRate
            )


        if runningMode == .normal,
           currentSpeed >= targetSpeed {

            if abs(
                lastAppliedRate - 1
            ) > 0.001 {

                playbackRate = 1

                lastAppliedRate = 1

                lastRateChangeTime =
                    Date()
            }

            return
        }


        if !force {

            if abs(
                limitedRate
                - lastAppliedRate
            ) < 0.05 {

                return
            }

            if Date()
                .timeIntervalSince(
                    lastRateChangeTime
                ) < 1 {

                return
            }
        }


        playbackRate =
            limitedRate

        lastAppliedRate =
            limitedRate

        lastRateChangeTime =
            Date()
    }
}
